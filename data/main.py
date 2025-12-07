import chromadb
from colinfo import ArchColInfo, RestaurantColInfo
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from sentence_transformers import CrossEncoder
import time
# Use a multilingual model for Vietnamese support
ef = SentenceTransformerEmbeddingFunction(model_name="BAAI/bge-m3", device="cuda")

reranker = CrossEncoder("E:/rr_model", device="cuda", model_kwargs={"dtype": "float16"})

client = chromadb.PersistentClient(path="./vector_db")
collection = client.get_or_create_collection(
    name='ct_data',
    embedding_function=ef
)
if (collection.count()==0):
    arch_info = ArchColInfo()
    collection.upsert(
        ids=arch_info.ids,
        documents=arch_info.documents,
        metadatas=arch_info.metadatas,
    )
    res_info = RestaurantColInfo()
    collection.upsert(
        ids=res_info.ids,
        documents=res_info.documents,
        metadatas=res_info.metadatas,
    )

test_query = [
    # 1. Architecture & Style (Tests 'arch_style' and specific descriptive keywords)
    "I want to visit a Hindu temple featuring Dravidian architecture.",
    "I am looking for a university with a mix of French and Chinese architecture.",
    "Show me a modernist style market built in the 1950s.",

    # # 2. Specific Function & Services (Tests semantic matching, e.g., 'Lung diseases' -> 'Lao và Bệnh Phổi')
    "Where is the leading hospital for Tuberculosis and Lung diseases?",
    "I want to find a place that serves as a spiritual center for the Tamil community.",
    "Show me the headquarters of the Customs Department.",

    # # 3. History & Heritage (Tests 'age' context and historical entities like 'Nguyen Dynasty')
    "I want to see the tomb of a general from the Nguyen Dynasty.",
    "Where is the ancient assembly hall of the Fujian Chinese community?",
    "Show me a historical hotel in District 5 with Vietnamese-Chinese architecture.",

    # # 4. Religion & Community (Tests 'religion' and cultural nuances)
    "I want to find a Catholic church in District 1 that is also a monastery.",
    "Where can I find a place of worship for the Muslim community?",
    "I want to visit a communal house dedicated to the tutelary god of the village." 
]

test_query_extended = [
    # --- 5. Culinary Heritage & Cuisine (New Category based on your CSV) ---
    # Tests 'food_type', specific dishes, and cultural dining styles
    "I want to try authentic royal Vietnamese cuisine in a traditional setting.", # Matches "Cung Đình" style
    "Show me a Halal restaurant suitable for Muslim tourists.", # Matches "Halal" tags
    "Where can I find a fine dining place serving international fusion food?", # Matches "International"
    "I am looking for a cozy spot for a traditional Vietnamese family meal.",
    "Show me a restaurant with a view that serves Asian cuisine.",

    # --- 6. Atmosphere & Experience (Tests descriptive adjectives) ---
    # Tests matching "vibe" or "experience" rather than just category
    "I want a romantic rooftop location for a dinner date.",
    "Find me a quiet place to drink tea and relax away from the noise.",
    "Show me a bustling night market where I can eat street food.",
    "I am looking for a luxury venue for a wedding reception.",

    # --- 7. Arts & Intangible Heritage (Tests specific cultural activities) ---
    # Tests concepts that might not be "places" but "activities" located at places
    "Where can I watch a traditional water puppet show?",
    "I want to find a gallery displaying contemporary Vietnamese art.",
    "Show me places where I can listen to traditional Don Ca Tai Tu music.",
    "Where can I see a live performance of Cai Luong opera?",

    # --- 8. Complex Cross-Domain Queries (Tests Location + Function) ---
    # Tests the model's ability to handle two requirements at once
    "Find me a French restaurant near the Notre Dame Cathedral.",
    "I want to visit a temple and then have a vegetarian lunch nearby.",
    "Show me a historical hotel that also serves high tea.",
    "I need a coffee shop with colonial architecture in District 3.",

    # --- 9. Historical Specificity (Tests deep knowledge entities) ---
    # Tests simpler 'fact-based' retrieval vs semantic retrieval
    "Where is the Independence Palace?",
    "Show me the location of the Turtle Lake roundabout.",
    "I want to visit the museum dedicated to War Remnants.",
    "Find the oldest colonial post office in the city."
]
# --- STEP 1: RETRIEVAL ---
# We retrieve MORE results than we need (e.g., top 10 or 20)
# to give the reranker a pool of candidates to sort.
initial_k = 10
final_k = 3

results = collection.query(
    query_texts=test_query_extended,
    n_results=initial_k 
)
before = time.perf_counter()
# --- STEP 2: RERANKING ---
for i, query_text in enumerate(test_query_extended):
    print(f"\nQuery {i+1}: {query_text}")
    
    # Extract documents and metadata for this specific query
    retrieved_docs = results['documents'][i]
    retrieved_metas = results['metadatas'][i]
    
    if not retrieved_docs:
        print("  No documents found.")
        continue

    # Prepare pairs for the Cross-Encoder: [[query, doc1], [query, doc2], ...]
    pairs = [[query_text, doc] for doc in retrieved_docs]
    
    # Calculate scores (High score = high relevance)
    scores = reranker.predict(pairs)
    
    # Combine everything: (score, document, metadata)
    combined_results = list(zip(scores, retrieved_docs, retrieved_metas))
    
    # Sort by score in descending order
    combined_results.sort(key=lambda x: x[0], reverse=True)

    for j, (score, doc, meta) in enumerate(combined_results[:final_k]):
        print(f"  {j+1}. {meta['name']}")
        # Optional: Print score to see confidence
        # print(f"     (Score: {score:.4f})")
after = time.perf_counter()
print(f"\nReranking Time: {after - before:.4f} seconds")