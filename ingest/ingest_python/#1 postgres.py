import psycopg2
import json
import os

# Path to the credentials file
CREDENTIALS_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'credentials', 'postgres_creds.json')

# Load credentials from JSON file
with open(CREDENTIALS_PATH, 'r') as f:
    creds = json.load(f)

schema = creds.pop('schema', None)

# Establish connection using unpacked credentials
db_connection = psycopg2.connect(**creds)
print("Connection successful!")

# check schema, if exists do nothing
#if schema:
#    with db_connection.cursor() as cur:
#        # Check if schema exists
#        cur.execute("SELECT schema_name FROM information_schema.schemata WHERE schema_name = %s", (schema,))
#        if not cur.fetchone():
#            print(f"Schema '{schema}' does not exist. Creating...")
#            cur.execute(f'CREATE SCHEMA "{schema}";')
#            db_connection.commit()
#        else:
#            print(f"Schema '{schema}' already exists.")

db_connection.close()