{{
    config(
        materialized = 'table',
        schema = 'assignment_production'
    )
}}

with
    -- messages table
    messages as (
        select 
            id,
            uuid, -- primary key for messages
            masked_addressees,
            masked_from_addr,
            content,
            message_type,
            direction,
            inserted_at::date as message_sent_at
        
        from {{ ref('messages') }}
    ),

    statuses as (
        select * from {{ ref('status') }}
    ),

    -- getting only status: sent data
    statuses_sent as (
        select 
            id as sent_status_id,
            uuid as sent_uuid, -- primary key for statuses
            message_uuid, -- foregin key for messages
            message_status as sent_status,
            updated_at as status_updated_at_sent,
            number_id
        
        from statuses
        where
            message_status = 'sent'
    ),

    -- getting only status: delivered data
    statuses_delivered as (
        select 
            id as delivered_status_id,
            uuid as delivered_uuid, -- primary key for statuses
            message_uuid, -- foregin key for messages
            message_status as delivered_status,
            updated_at as status_updated_at_delivered,
            number_id
        
        from statuses
        where
            message_status = 'delivered'
    ),

    -- getting only status: read data
    statuses_read as (
        select 
            id as read_status_id,
            uuid as read_uuid, -- primary key for statuses
            message_uuid, -- foregin key for messages
            message_status as read_status,
            updated_at as status_updated_at_read,
            number_id
        
        from statuses
        where
            message_status = 'read'
    ),

    -- getting only status: failed data
    statuses_failed as (
        select 
            id as failed_status_id,
            uuid as failed_uuid, -- primary key for statuses
            message_uuid, -- foregin key for messages
            message_status as failed_status,
            updated_at as status_updated_at_failed,
            number_id
        
        from statuses
        where
            message_status = 'failed'
    ),

    -- getting only status: deleted data
    statuses_deleted as (
        select 
            id as deleted_status_id,
            uuid as deleted_uuid, -- primary key for statuses
            message_uuid, -- foregin key for messages
            message_status as deleted_status,
            updated_at as status_updated_at_deleted,
            number_id
        
        from statuses
        where
            message_status = 'deleted'
    ),

    -- latest status
    latest_status as (
        {{ dbt_utils.deduplicate(
            relation='statuses',
            partition_by='message_uuid',
            order_by='updated_at desc',
           )
        }}
    ),

-- joining message table with statuses table with all the statuses: id, uuid, message_status, status_updated_at, number_id
    message_status_joined as (
        select 
            messages.uuid as uuid, -- primary key

            coalesce(statuses_sent.number_id, statuses_delivered.number_id, statuses_read.number_id, statuses_failed.number_id, statuses_deleted.number_id) as number_id,

            -- getting user phone number
            case
                when messages.direction = 'outbound' then messages.masked_addressees
                when messages.direction = 'inbound' then messages.masked_from_addr
            end as user_phone_number,

            messages.content,
            messages.message_type,
            messages.direction,
            messages.message_sent_at,

            -- latest status
            latest_status.message_status as latest_message_status,
            latest_status.updated_at as latest_message_status_timestamp,

            -- sent meta data
            statuses_sent.sent_status_id,
            statuses_sent.sent_uuid,
            statuses_sent.sent_status,
            statuses_sent.status_updated_at_sent,

            -- delivered meta data
            statuses_delivered.delivered_status_id,
            statuses_delivered.delivered_uuid,
            statuses_delivered.delivered_status,
            statuses_delivered.status_updated_at_delivered,

            -- read meta data
            statuses_read.read_status_id,
            statuses_read.read_uuid,
            statuses_read.read_status,
            statuses_read.status_updated_at_read,
            
            -- failed meta data
            statuses_failed.failed_status_id,
            statuses_failed.failed_uuid,
            statuses_failed.failed_status,
            statuses_failed.status_updated_at_failed,
            
            -- deleted meta data
            statuses_deleted.deleted_status_id,
            statuses_deleted.deleted_uuid,
            statuses_deleted.deleted_status,
            statuses_deleted.status_updated_at_deleted,

            (EXTRACT(epoch FROM (statuses_read.status_updated_at_read - messages.message_sent_at)) / 3600.0) as read_time_hours

        from messages

        left join latest_status 
        on messages.uuid = latest_status.message_uuid

        left join statuses_sent 
        on messages.uuid = statuses_sent.message_uuid

        left join statuses_delivered 
        on messages.uuid = statuses_delivered.message_uuid

        left join statuses_read 
        on messages.uuid = statuses_read.message_uuid

        left join statuses_failed 
        on messages.uuid = statuses_failed.message_uuid

        left join statuses_deleted 
        on messages.uuid = statuses_deleted.message_uuid
    )

select 
    * ,
    case
        when read_time_hours < 0.5 then 'less than 0.5 hour'
        when read_time_hours >= 0.5 and read_time_hours < 1 then 'between 0.5 hour and 1 hour'
        when read_time_hours >= 1 and read_time_hours < 6 then 'between 1 hour and 6 hours'
        when read_time_hours >= 6 and read_time_hours < 12 then 'between 6 hours and 12 hours'
        when read_time_hours >= 12 and read_time_hours < 24 then 'between 12 hours and 24 hours'
        when read_time_hours >= 24 and read_time_hours < 72 then 'between 1 day and 3 days'
        else 'more than 3 days'
    end as read_time_hours_category
from message_status_joined
