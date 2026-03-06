{{
  dbt_utils.date_spine(
    datepart="month",
    start_date="(select date_trunc('month', min(subscription_start_date)) from " ~ ref('stg_subscriptions') ~ ")",
    end_date="(select dateadd(month, 2, date_trunc('month', max(subscription_end_date))) from " ~ ref('stg_subscriptions') ~ ")"
  )
}}