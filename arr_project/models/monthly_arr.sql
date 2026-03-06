with spine as (

    select
        date_month,
        last_day(date_month) as month_end
    from {{ ref('date_spine') }}

),

subs as (

    select
        account_id,
        subscription_id,
        subscription_start_date,
        subscription_end_date,
        subscription_arr_usd
    from {{ ref('stg_subscriptions') }}

),

expanded as (

    select
        s.account_id,
        s.subscription_id,
        sp.date_month,
        sp.month_end,
        s.subscription_arr_usd
    from subs s
    join spine sp
      on s.subscription_start_date <= sp.month_end
     and (
          s.subscription_end_date is null
          or s.subscription_end_date >= sp.month_end
     )

),

final as (

    -- subscription-month grain (one row per subscription per month)
    select
        account_id,
        subscription_id,
        date_month,
        month_end,
        subscription_arr_usd / 12 as MRR_USD
    from expanded

)

select *
from final