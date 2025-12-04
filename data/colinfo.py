import hashlib
import pandas as pd

# --- 1. The Parent Class (Shared Logic) ---
class BaseColInfo:
    def __init__(self, csv_file):
        self.df = pd.read_csv(csv_file)
        self.documents = []
        self.ids = []
        self.metadatas = []
        
        # We call the processing steps here
        self._process_doc()             # Child classes will define how to do this
        self._process_metadata_and_ids() # Parent class handles this

    def _process_doc(self):
        """Placeholder: Child classes must override this method."""
        raise NotImplementedError("Subclasses must implement _process_doc")

    def _process_metadata_and_ids(self):
        """Common logic for IDs and Metadata."""
        self.ids = []
        for doc_text in self.documents:
            # Create a unique hash (MD5) based on the text content
            doc_hash = hashlib.md5(doc_text.encode('utf-8')).hexdigest()
            self.ids.append(doc_hash)
        
        # Check specific columns for metadata
        cols_to_keep = ["name"]
        if "image link" in self.df.columns:
            cols_to_keep.append("image link")
            
        # Use .fillna("") to ensure metadata doesn't break on NaNs
        self.metadatas = self.df[cols_to_keep].fillna("").to_dict(orient="records")


# --- 2. Architecture Child Class ---
class ArchColInfo(BaseColInfo):
    def __init__(self, csv_file="CT_Data - Architecture.csv"):
        # Initialize the parent class
        super().__init__(csv_file)

    def _process_doc(self):
        for _, row in self.df.iterrows():
            age = str(int(row['age'])) if pd.notnull(row['age']) else "unknown date"
            style = row['arch_style'] if pd.notnull(row['arch_style']) else "unknown style"
            b_type = row['building_type'] if pd.notnull(row['building_type']) else "building"
            desc = row['description'] if pd.notnull(row['description']) else ""
            
            rich_text = f"{row['name']} is a {style} {b_type} built in {age}. {desc}"
            self.documents.append(rich_text)


# --- 3. Restaurant Child Class ---
class RestaurantColInfo(BaseColInfo):
    def __init__(self, csv_file="Restaurant_Data.csv"):
        # Initialize the parent class
        super().__init__(csv_file)

    def _process_doc(self):
        for _, row in self.df.iterrows():
            name = row['name'] if pd.notnull(row['name']) else "unknown name"
            food_type = row['food_type'] if pd.notnull(row['food_type']) else "various"
            rich_text = f"{name} is a restaurant serving {food_type} food."
            self.documents.append(rich_text)