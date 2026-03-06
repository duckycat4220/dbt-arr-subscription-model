with base as (

    select
        subscription_id,
        date_month,
        month_end,
        mrr_usd
    from {{ ref('subscription_months') }}

),

first_active as (

    select
        subscription_id,
        min(date_month) as first_active_month
    from base
    where mrr_usd > 0
    group by 1

),

with_prev as (

    select
        b.*,
        lag(mrr_usd) over (
            partition by subscription_id
            order by date_month
        ) as prev_mrr_usd
    from base b

),

final as (

    select
        w.subscription_id,
        w.date_month,
        w.month_end,
        w.mrr_usd,
        w.prev_mrr_usd,

        case
            when w.mrr_usd > 0 and w.date_month = f.first_active_month then 'new'
            when w.prev_mrr_usd > 0 and w.mrr_usd = 0 then 'churn'
            when w.prev_mrr_usd = 0 and w.mrr_usd > 0 then 'reactivation'
            when w.mrr_usd > w.prev_mrr_usd then 'expansion'
            when w.mrr_usd < w.prev_mrr_usd then 'contraction'
            else 'no_change'
        end as arr_change_category,

        (w.mrr_usd - coalesce(w.prev_mrr_usd, 0)) as mrr_change_usd,
        (w.mrr_usd - coalesce(w.prev_mrr_usd, 0)) * 12 as arr_change_usd

    from with_prev w
    left join first_active f
      on w.subscription_id = f.subscription_id

)

select *
from final