{{
  config(
    materialized = 'table',
    schema = 'assignment_production'
    )
}}

with
    messages as (
        select * from {{ ref('messages_intermediate') }}
    )

-- eliminating duplicate data
{{ dbt_utils.deduplicate(
    relation='messages',
    partition_by='id',
    order_by='updated_at desc',
   )
}}