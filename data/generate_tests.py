import pandas as pd
import json
import torch
import random
import re
from tqdm import tqdm
from transformers import T5Tokenizer, T5ForConditionalGeneration

# --- CONFIGURATION ---
CSV_PATH = 'E:/CT_Data - Architecture.csv' 
OUTPUT_FILE = "cultural_test_dataset_english.json"
NUM_TEST_CASES = 500
MODEL_NAME = 'google/flan-t5-large' 
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# --- 1. STRICT ENGLISH PROMPTS ---
# Key changes: Added "Language: English Only" and instructions to translate if needed.
PERSONAS = {
    "vibe": """
Task: Write a Google search query based on the description below.
User Persona: An English-speaking traveler looking for a specific atmosphere.
Language: STRICTLY ENGLISH. (If the description is Vietnamese, translate the concept to English).
Constraint: Do NOT use the exact name of the place. Use descriptive English words.

Example 1:
Description: Một ngôi chùa yên tĩnh nằm trên đồi với rừng thông. (Name: Thien An Monastery)
Query: peaceful meditation spot on a hill with pine trees

Example 2:
Description: A bustling market in the center of the city with a large clock tower. (Name: Ben Thanh Market)
Query: busy central market with street food and clock tower

Target:
Description: {description} (Name: {name})
Query:""",

    "architect": """
Task: Write a search query for a building based on its architecture.
User Persona: An English-speaking architecture student.
Language: STRICTLY ENGLISH.
Constraint: Do NOT use the exact name. Focus on structure, style, and design in English.

Example 1:
Description: Nhà thờ màu hồng phong cách Romanesque. (Name: Tan Dinh Church)
Query: pink roman style catholic church architecture

Example 2:
Description: A modern brutalist government building made of concrete with sharp angles. (Name: Independence Palace)
Query: 1960s concrete brutalist landmark

Target:
Description: {description} (Name: {name})
Query:""",

    "activity": """
Task: Write a search query finding a place to do specific activities.
User Persona: An English-speaking tourist looking for an experience.
Language: STRICTLY ENGLISH.
Constraint: Do NOT use the exact name. Describe the activity in English.

Example 1:
Description: Công viên nơi người dân tập thể dục buổi sáng. (Name: Tao Dan Park)
Query: best park for jogging and morning exercise

Example 2:
Description: An opera house that hosts cultural shows and bamboo circus performances. (Name: Saigon Opera House)
Query: watch bamboo circus and cultural shows

Target:
Description: {description} (Name: {name})
Query:"""
}

def clean_query(text):
    """Cleans artifacts and helps enforce English characters."""
    # Remove common model prefixes
    text = re.sub(r'^(Query:|Search query:|Result:)', '', text, flags=re.IGNORECASE).strip()
    text = text.replace('"', '').replace("'", "")
    
    # Optional: Filter out if the model completely failed and outputted Vietnamese characters
    # (Checking for common Vietnamese diacritics like ư, ơ, ê, â, ô, etc.)
    # strict_english_check = re.search(r'[ưMwơưêâôáàảãạđ]', text)
    # if strict_english_check:
    #     return None 

    if len(text) < 5: return None
    return text.lower()

def generate_id(row):
    lat = row.get('location.lat') or row.get('lat')
    lon = row.get('location.lon') or row.get('lon')
    if pd.notnull(lat) and pd.notnull(lon):
        return f"{lat}_{lon}"
    return f"unknown_{row.name}"

def main():
    print(f"📂 Loading data from {CSV_PATH}...")
    try:
        df = pd.read_csv(CSV_PATH)
    except FileNotFoundError:
        print(f"❌ Error: {CSV_PATH} not found.")
        return

    # Use refined_description if available, else description
    if 'refined_description' in df.columns:
        df['description'] = df['refined_description'].fillna(df['description'])
    
    # Fill NaNs
    df['description'] = df.get('description', '').fillna('')
    df['name'] = df.get('name', 'Unknown').fillna('Unknown')

    print(f"🤖 Loading Model ({MODEL_NAME})...")
    tokenizer = T5Tokenizer.from_pretrained(MODEL_NAME)
    model = T5ForConditionalGeneration.from_pretrained(MODEL_NAME)
    model.to(DEVICE)
    model.eval()

    # Sample data
    if len(df) < NUM_TEST_CASES:
        sample_df = df.sample(n=NUM_TEST_CASES, replace=True, random_state=42)
    else:
        sample_df = df.sample(n=NUM_TEST_CASES, random_state=42)

    results = []
    print(f"🚀 Generating {NUM_TEST_CASES} fully English test cases...")

    for _, row in tqdm(sample_df.iterrows(), total=NUM_TEST_CASES):
        desc = str(row['description'])
        name = str(row['name'])
        
        if len(desc) < 15: continue

        # 1. Select Persona
        persona_key = random.choice(list(PERSONAS.keys()))
        prompt_template = PERSONAS[persona_key]

        # 2. Format Prompt
        # Truncate desc to fit context. 
        input_text = prompt_template.format(description=desc[:400], name=name)

        # 3. Generate
        input_ids = tokenizer.encode(input_text, max_length=1024, truncation=True, return_tensors='pt').to(DEVICE)

        with torch.no_grad():
            outputs = model.generate(
                input_ids=input_ids,
                max_length=64,
                do_sample=True,
                temperature=0.85, # Slightly lower temp to keep it focused on English
                top_p=0.95,
                repetition_penalty=1.2,
                num_return_sequences=1
            )

        raw_query = tokenizer.decode(outputs[0], skip_special_tokens=True)
        final_query = clean_query(raw_query)

        if not final_query: continue

        # 4. Construct Result
        target_id = generate_id(row)
        
        results.append({
            "query": final_query,
            "relevant_ids": [target_id],
            "type": f"Semantic ({persona_key.capitalize()} - English)"
        })

    # Save
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Saved {len(results)} queries to '{OUTPUT_FILE}'")

if __name__ == "__main__":
    main()