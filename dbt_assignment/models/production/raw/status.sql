{{
  config(
    materialized = 'table',
    schema = 'assignment_production'
    )
}}

with
    statuses as (
        select * from {{ ref('status_intermediate') }}
    ),

    -- eliminating duplicate rows
    status_dedup as (
        {{ dbt_utils.deduplicate(
            relation='statuses',
            partition_by='id',
            order_by='updated_at desc',
           )
        }}
    )

 -- eliminating duplicate rows based on message and message status
{{ dbt_utils.deduplicate(
    relation='status_dedup',
    partition_by='message_uuid, message_status',
    order_by='updated_at desc',
    )
}}