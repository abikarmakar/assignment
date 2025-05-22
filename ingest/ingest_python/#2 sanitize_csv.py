import pandas as pd
from pathlib import Path

# Directory containing the CSV files
CSV_DIR = Path(__file__).parent.parent / 'csv_raw'

# List all CSV files in the directory
csv_files = list(CSV_DIR.glob('*.csv'))

# path to store new csv files
NEW_CSV_DIR = Path(__file__).parent.parent / 'csv_new'
# create directory if not exists
NEW_CSV_DIR.mkdir(exist_ok=True)

created_count = 0
for csv_file in csv_files:
    print(f"Reading {csv_file.name}...")
    df = pd.read_csv(csv_file)
    if not df.empty:
        # Sanitize columns
        sanitized_columns = [col.strip().lower().replace(' ', '_') for col in df.columns]
        df.columns = sanitized_columns
        print(f"Sanitized columns:")
        print(sanitized_columns)
        # Save to new directory with same filename
        new_csv_path = NEW_CSV_DIR / csv_file.name
        df.to_csv(new_csv_path, index=False)
        print(f"Saved sanitized CSV to {new_csv_path}")
        created_count += 1
    else:
        print("CSV is empty.")
    print("-")

print(f"Total sanitized CSV files created and stored in '{NEW_CSV_DIR}': {created_count}")