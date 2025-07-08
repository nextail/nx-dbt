{{
    config(
        materialized='incremental',
        unique_key=['email', 'datetime']
    )
}}

select 
    lower(user) as email,
    split(email, '@')[0]::TEXT as user_name,
    split(email, '@')[1]::TEXT as user_domain,
    ip,
    country,
    device_type,
    case 
        when upper(device_type) in ('UNKNOWN', 'COMPUTER') then 'WEB'
        when upper(device_type) = 'MOBILE' then 'MOBILE'
        when upper(device_type) = 'TABLET' then 'TABLET'
        else 'OTHER'
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