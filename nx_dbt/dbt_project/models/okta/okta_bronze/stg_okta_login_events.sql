{{
    config(
        materialized='incremental',
        unique_key=['user', 'datetime']
    )
}}

select 
    user,
    split(user, '@')[0]::TEXT as user_name,
    split(user, '@')[1]::TEXT as user_domain,
    split(user_domain, '.')[0]::TEXT as tenant,
    ip,
    country,
    case 
        when upper(device_type) in ('UNKNOWN', 'COMPUTER') then 'Web'
        when upper(device_type) = 'MOBILE' then 'Mobile'
        else 'Other'
    end as device,
    datetime,
    integration,
    event_type,
    nullif(redirect_uri, 'null') as redirect_uri,
    user_agent,
from {{ source('okta_public', 'login_event') }}

{% if is_incremental() %}
    where datetime > (select max(datetime) from {{ this }})
{% endif %}