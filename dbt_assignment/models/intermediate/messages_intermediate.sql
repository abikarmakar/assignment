{{
  config(
    materialized = 'table',
    schema = 'assignment_intermediate'
    )
}}

with

    -- getting messages from source
    messages as (
        select 
            id,
            uuid,
            nullif(content, 'NaN') as content,
            message_type,
            direction,
            masked_addressees,
            masked_from_addr,
            -- converting timestamp to YYYY-MM-DD HH24:MI:SS format
            to_char(to_timestamp(inserted_at, 'MM/DD/YYYY HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') as inserted_at,
            to_char(to_timestamp(updated_at, 'MM/DD/YYYY HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') as updated_at
            
        from {{ source('chatbot_data', 'raw_messages') }}
    ),

    -- converting timestamp to YYYY-MM-DD HH24:MI:SS format
    messages_updated as (

        select
            id,
            uuid,
            content,
            message_type,
            direction,
            masked_addressees,
            masked_from_addr,
            -- converting timestamp to YYYY-MM-DD HH24:MI:SS format
            to_timestamp(inserted_at, 'YYYY-MM-DD HH24:MI:SS') as inserted_at,
            to_timestamp(updated_at, 'YYYY-MM-DD HH24:MI:SS') as updated_at
        
        from messages
    )

select * from messages_updated
