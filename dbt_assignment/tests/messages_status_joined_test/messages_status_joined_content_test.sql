-- test to find duplicate/similar content

with 
    duplicate_content as (
        select
            content, count(*)
        from {{ ref('messages_status_joined') }}
        where content is not null
group by content
having count(*) > 1
    )
    
select * from duplicate_content