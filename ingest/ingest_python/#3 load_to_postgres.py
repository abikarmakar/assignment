import psycopg2
import json
from pathlib import Path
import pandas as pd

# Load credentials
CREDENTIALS_PATH = Path(__file__).parent.parent / 'credentials' / 'postgres_creds.json'
with open(CREDENTIALS_PATH, 'r') as f:
    creds = json.load(f)
schema = creds.pop('schema', None)

# Directory with sanitized CSVs
data_dir = Path(__file__).parent.parent / 'csv_new'
csv_files = list(data_dir.glob('*.csv'))
print(f"Found {len(csv_files)} CSV files in {data_dir}.")

with psycopg2.connect(**creds) as conn:
    cur = conn.cursor()
    # check schema, if exists do nothing
    if schema:
        cur.execute("SELECT schema_name FROM information_schema.schemata WHERE schema_name = %s", (schema,))
        if not cur.fetchone():
            print(f"Schema '{schema}' does not exist. Creating...")
            cur.execute(f'CREATE SCHEMA "{schema}";')
            conn.commit()
        else:
            print(f"Schema '{schema}' already exists.")
    # load csv files
    for csv_file in csv_files:
        print(f"\nProcessing file: {csv_file.name}")
        df = pd.read_csv(csv_file)
        table_name = csv_file.stem.lower()
        qualified_table = f'"{schema}"."{table_name}"' if schema else f'"{table_name}"'
        columns_with_types = ', '.join([f'"{col}" TEXT' for col in df.columns])
        print(f"Dropping table if exists: {qualified_table} ...")
        cur.execute(f'DROP TABLE IF EXISTS {qualified_table} CASCADE;')
        print(f"Creating table: {qualified_table} ...")
        cur.execute(f'CREATE TABLE {qualified_table} ({columns_with_types});')
        print(f"Table ready. Inserting rows...")
        row_count = 0
        # insert rows
        for row in df.itertuples(index=False, name=None):
            placeholders = ', '.join(['%s'] * len(df.columns))
            insert_sql = f'INSERT INTO {qualified_table} ({', '.join([f'"{col}"' for col in df.columns])}) VALUES ({placeholders});'
            try:
                cur.execute(insert_sql, row)
                row_count += 1
            except Exception as e:
                print(f"Error inserting row: {e}")
        conn.commit()
        
        print(f"Inserted {row_count} rows into {qualified_table}.")
    print("\nAll CSVs processed and loaded into Postgres.")
