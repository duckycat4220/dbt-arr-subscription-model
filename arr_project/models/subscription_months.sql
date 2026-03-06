with spine as (

    select
        date_month,
        last_day(date_month) as month_end
    from {{ ref('date_spine') }}

),

subs as (

    select
        subscription_id,
        subscription_start_date,
        subscription_end_date,
        subscription_arr_usd
    from {{ ref('stg_subscriptions') }}

),

all_months as (

    select
        s.subscription_id,
        sp.date_month,
        sp.month_end,
        s.subscription_start_date,
        s.subscription_end_date,
        s.subscription_arr_usd
    from subs s
    cross join spine sp

),

final as (

    select
        subscription_id,
        date_month,
        month_end,

        case
            when subscription_start_date <= month_end
             and month_end <= dateadd(month, 1, subscription_end_date)
            then subscription_arr_usd / 12
            else 0
        end as mrr_usd

    from all_months

)

select *
from final