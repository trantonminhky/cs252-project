import chromadb
from colinfo import ArchColInfo
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction

# Use a multilingual model for Vietnamese support
ef = SentenceTransformerEmbeddingFunction(model_name="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", device="cuda")

client = chromadb.PersistentClient(path="./vector_db")

collection = client.get_or_create_collection(
    name="ct_data",
    embedding_function=ef
)

arch_info = ArchColInfo()

collection.upsert(
    ids=arch_info.ids,
    documents=arch_info.documents,
    metadatas=arch_info.metadatas,
)
test_query = [
    # 1. Architecture & Style (Tests 'arch_style' and specific descriptive keywords)
    "I want to visit a Hindu temple featuring Dravidian architecture.",
    "I am looking for a university with a mix of French and Chinese architecture.",
    "Show me a modernist style market built in the 1950s.",

    # 2. Specific Function & Services (Tests semantic matching, e.g., 'Lung diseases' -> 'Lao và Bệnh Phổi')
    "Where is the leading hospital for Tuberculosis and Lung diseases?",
    "I want to find a place that serves as a spiritual center for the Tamil community.",
    "Show me the headquarters of the Customs Department.",

    # 3. History & Heritage (Tests 'age' context and historical entities like 'Nguyen Dynasty')
    "I want to see the tomb of a general from the Nguyen Dynasty.",
    "Where is the ancient assembly hall of the Fujian Chinese community?",
    "Show me a historical hotel in District 5 with Vietnamese-Chinese architecture.",

    # 4. Religion & Community (Tests 'religion' and cultural nuances)
    "I want to find a Catholic church in District 1 that is also a monastery.",
    "Where can I find a place of worship for the Muslim community?",
    "I want to visit a communal house dedicated to the tutelary god of the village." 
]
results = collection.query(
    query_texts=test_query,
    n_results=3
)
for i, result in enumerate(results["documents"]):
    print(f"Query {i+1}:")
    for j,doc in enumerate(result):
        print(f"  {j+1}. {results['metadatas'][i][j]['name']}") # Print the Name from metadata
