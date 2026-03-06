with source as (

    select *
    from {{ ref('subscriptions') }}

),

staged as (

    select
        account_id::varchar                 as account_id,
        subscription_id::varchar            as subscription_id,
        subscription_quantity::number       as subscription_quantity,

        try_to_date(subscription_deal_close_date) as subscription_deal_close_date,
        subscription_product_line::varchar        as subscription_product_line,
        subscription_status::varchar              as subscription_status,
        try_to_date(subscription_start_date)      as subscription_start_date,
        try_to_date(subscription_end_date)        as subscription_end_date,

        subscription_arr_usd::number(38, 9)  as subscription_arr_usd
    from source

)

select *
from staged