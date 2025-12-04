import chromadb
import uuid
import pandas as pd

client = chromadb.Client()

collection = client.get_or_create_collection("ct_data")

df = pd.read_csv("CT_Data - Architecture.csv")

names = df["name"].tolist()
descriptions = df["description"].tolist()

desc_to_name = dict(zip(descriptions, names))

ids = [str(uuid.uuid4()) for _ in descriptions]
collection.add(
    ids=ids,
    documents=descriptions,
    metadatas=[{"name": name} for name in names]
)
results = collection.query(
    query_texts=[
        "tôi muốn đi chợ",
        "cơ sở chính do Thành phố quản lý và có quy mô lớn"
    ],
    n_results=1
)
for i, result in enumerate(results["documents"]):
    print(f"Query {i+1}:")
    for doc in result:
        print(desc_to_name[doc]+"\n")
