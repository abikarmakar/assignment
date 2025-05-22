-- test to find similar inserted_at (message_sent_at)

with 
    duplicate_message_sent_at as (
        select
            message_sent_at, count(*)
        from {{ ref('messages_status_joined') }}
        group by message_sent_at
        having count(*) > 1
    )

select * from duplicate_message_sent_at