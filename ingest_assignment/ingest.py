import psycopg2
import json
import os

# Path to the credentials file
CREDENTIALS_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'credentials', 'postgres_creds.json')

# Load credentials from JSON file
with open(CREDENTIALS_PATH, 'r') as f:
    creds = json.load(f)

# Establish connection using unpacked credentials
db_connection = psycopg2.connect(**creds)
print("Connection successful!")

db_connection.close()