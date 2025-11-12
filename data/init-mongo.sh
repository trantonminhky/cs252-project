#!/bin/bash

# Base path where we mounted the data inside the container
DATA_PATH="/tmp/data"

echo "🚀 STARTING AUTOMATIC IMPORT..."

# Loop through every folder inside /tmp/data
for db_folder in $DATA_PATH/*; do
    # Check if it is actually a directory (ignore files like the script itself)
    if [ -d "$db_folder" ]; then
        
        # Get the folder name (this will be the DB name)
        db_name=$(basename "$db_folder")
        
        echo "📂 Found Database Folder: $db_name"

        # Loop through every JSON file inside that folder
        for json_file in "$db_folder"/*.json; do
            if [ -f "$json_file" ]; then
                
                # Get the filename without extension (this will be the Collection name)
                filename=$(basename "$json_file")
                collection_name="${filename%.*}"

                echo "   📄 Importing $collection_name into $db_name..."

                # Run the import
                mongoimport --host localhost --db "$db_name" --collection "$collection_name" --file "$json_file" --jsonArray --drop
            fi
        done
    fi
done

echo "✅ FINISHED IMPORTING ALL DATA"