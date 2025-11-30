import pandas as pd
from app.config import settings

def load_heritage_data() -> pd.DataFrame:
    """
    Loads and cleans the Vietnamese heritage dataset.
    """
    if not settings.RAW_DATA_PATH.exists():
        raise FileNotFoundError(f"CSV not found at {settings.RAW_DATA_PATH}")

    df = pd.read_csv(settings.RAW_DATA_PATH)
    
    # Clean ID column (removing "way", "node" wrappers if necessary)
    #  shows IDs like "('way', 39514795)"
    df['clean_id'] = df['id'].apply(lambda x: str(x).replace("('way', ", "").replace("('node', ", "").replace("('relation', ", "").replace(")", ""))

    # Normalize missing values
    df.fillna({
        'arch_style': 'unknown',
        'religion': 'none',
        'building_type': 'general',
        'tags': ''
    }, inplace=True)
    
    return df