{{
  config(
    materialized = 'table',
    schema = 'assignment_intermediate'
    )
}}

with
    -- getting statuses from source
    statuses as (
        select 
            id,
            uuid,
            message_uuid,
            number_id,
            status as message_status,
            -- converting timestamp to YYYY-MM-DD HH24:MI:SS format
            to_char(to_timestamp(updated_at, 'MM/DD/YYYY HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') as updated_at
            
        from {{ source('chatbot_data', 'raw_statuses') }}
    ),

    -- converting timestamp to YYYY-MM-DD HH24:MI:SS format
    statuses_updated as (
        select
            id,
            uuid,
            message_uuid,
            number_id,
            message_status,
            to_timestamp(updated_at, 'YYYY-MM-DD HH24:MI:SS') as updated_at
        
        from statuses
    )

select * from statuses_updated