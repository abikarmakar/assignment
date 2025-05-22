# pre-requisites
1. python 3.12+
2. dbt (store data warehouse credentials in **.dbt** where dbt in installed)
3. Datawarehouse(postgresql) credentials in **ingest/credentials/postgres_creds.json**
4. Downaloded csv files into **ingest/csv_raw** directory
5. Superset 4.1.1 for Data visualization.

# Ingest data: directory:- assignment\ingest
1. ingest/credentials/postgres_creds.json
 
 **Description:** Needs to have the credntials for warehouse where data will be loaded.
 We are using postgresql as warehouse.

 **Code Run:** No

2. ingest/ingest_python/#1 postgres.py

 **Description:** Checks the credentials in the file and connects to warehouse.
 
 **Code Run:** Yes

3. ingest/ingest_python/#2 sanitize_csv.py

 **Description:** Reads the csv files from ingest/csv_raw directory and sanitizes the column names.
 Stores the new sanitized csv files in ingest/csv_new directory.
 
 **Code Run:** Yes

4. ingest/ingest_python/#3 load_to_postgres.py

 **Description:** Reads the csv files from ingest/csv_new directory and loads the data into postgresql.
 Loads the data into schema: assignment_staging
 
 **Code Run:** Yes

# Transformation (dbt) directory:- assignment\dbt_assignment
## models\staging
1. source.yml

 **Description:** Stores the source of data.
 
 **Code Run:** No

## models\intermediate
1. int.yml

 **Description:** Stores the intermediate data docs, tests, description.
 
 **Code Run:** No

2. messages_intermediate.sql

 **Description:** Stores the messages intermediate data from messages table. Meta data and tests stored in int.yml
 
 **Code Run:** Yes

3. messages_intermediate.sql

 **Description:** Stores the messages intermediate data from messages table. Meta data and tests stored in int.yml
 
 **Code Run:** Yes

4. status_intermediate.sql

 **Description:** Stores the statuses intermediate data from statuses table. Meta data and tests stored in int.yml
 
 **Code Run:** Yes

## models\production
1. prod.yml

 **Description:** Stores the production data docs, tests, description.
 
 **Code Run:** No

2. messages.sql

 **Description:** Stores the messages data after removing duplicates from messages_intermediate table.
 
 **Code Run:** Yes

3. statuses.sql

 **Description:** Stores the statuses data after removing duplicates from statuses_intermediate table.
 
 **Code Run:** Yes

4. messages_status_joined.sql

 **Description:** Stores the messages and statuses data joined. Meta data and tests stored in prod.yml
 
 **Code Run:** Yes

## tests
1. messages_status_joined_test\messages_status_joined_content_test.sql

 **Description:** Tests the messages and status joined data to check for duplicate content.
 
 **Code Run:** Yes

2. messages_status_joined_test\messages_status_joined_message_sent_at_test.sql

 **Description:** Tests the messages and status joined data to check for message sent at.
 
 **Code Run:** Yes

# Visualization
## Superset
    Usage of Superset 4.1.1 for data visualization.
    Images stored in visualization
    Timeline used (last 6 months):- '2023-10-01' to '2024-04-01'
    Timeline used (last 1 week):- '2024-13-25' to '2024-04-01'
### Summary
    1. Total Users_week-wise_last 6 months
    Description: Total users week-wise in last 6 months
    2. Active Users_week-wise_last 6 months
    Description: Active users week-wise in last 6 months
### Message Analysis
    1. Non-failed_Messages read_week-wise_last 6 months
    Description: % of Non-failed messages read week-wise in last 6 months
    2. Outbound Message_Latest Status_Last week
    Description: Outbound messages latest status last week
    3. Outbound Message_Read time Distribution_Last week
    Description: Outbound messages read time distribution last week

# Full process to run

## Ingest: Run
1. ingest/ingest_python/#1 postgres.py
2. ingest/ingest_python/#2 sanitize_csv.py
3. ingest/ingest_python/#3 load_to_postgres.py

## Transformation (dbt): Run
1. dbt debug
    To check connection
2. dbt clean
    Clean packages, targets
3. dbt deps
    Install dependencies
4. dbt run
    Runs all dbt models
5. dbt test
    Runs all dbt tests.
    Failed test's are stored in test_failures schema. Along with select query for failed tests in terminal.
6. dbt docs generate
    Generate docs
7. dbt docs serve
    Serve docs
