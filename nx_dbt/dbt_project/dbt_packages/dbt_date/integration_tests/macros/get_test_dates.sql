{% macro get_test_dates() -%}
    select
        cast('2020-11-29' as date) as date_day,
        cast('2020-11-28' as date) as prior_date_day,
        cast('2020-11-30' as date) as next_date_day,
        'Sunday' as day_name,
        'Sun' as day_name_short,
        'zondag' as day_name_long_dutch,
        'So' as day_name_short_german,
        29 as day_of_month,
        1 as day_of_week,
        7 as iso_day_of_week,
        334 as day_of_year,
        cast('{{ get_test_week_start_date()[0] }}' as date) as week_start_date,
        cast('{{ get_test_week_end_date()[0] }}' as date) as week_end_date,
        {{ get_test_week_of_year()[0] }} as week_of_year,
        -- in ISO terms, this is the end of the prior week
        cast('2020-11-23' as date) as iso_week_start_date,
        cast('2020-11-29' as date) as iso_week_end_date,
        48 as iso_week_of_year,
        '2020-W48' as iso_year_week,
        11 as month_number,
        'November' as month_name,
        'Nov' as month_name_short,
        'november' as month_name_dutch,
        'Nov' as month_name_short_german,
        1623076520 as unix_epoch,
        cast(
            '{{ get_test_timestamps()[0] }}' as {{ dbt.type_timestamp() }}
        ) as time_stamp,
        cast(
            '{{ get_test_timestamps()[1] }}' as {{ dbt.type_timestamp() }}
        ) as time_stamp_utc,
        cast('2021-06-07' as {{ dbt.type_timestamp() }}) as rounded_timestamp,
        cast('2021-06-08' as {{ dbt.type_timestamp() }}) as rounded_timestamp_utc,
        -- These columns are here to make sure these macros get run during testing:
        {{ dbt_date.last_month_number() }} as last_month_number,
        {{ dbt_date.last_month_name(short=False) }} as last_month_name,
        {{ dbt_date.last_month_name(short=True) }} as last_month_name_short,
        {{ dbt_date.next_month_number() }} as next_month_number,
        {{ dbt_date.next_month_name(short=False) }} as next_month_name,
        {{ dbt_date.next_month_name(short=True) }} as next_month_name_short,
        cast('{{ modules.datetime.date(1997, 9, 29) }}' as date) as datetime_date,
        cast(
            '{{ modules.datetime.datetime(1997, 9, 29, 6, 14, 0, tzinfo=modules.pytz.timezone(var("dbt_date:time_zone"))) }}'
            as {{ dbt.type_timestamp() }}
        ) as datetime_datetime

    union all

    select
        cast('2020-12-01' as date) as date_day,
        cast('2020-11-30' as date) as prior_date_day,
        cast('2020-12-02' as date) as next_date_day,
        'Tuesday' as day_name,
        'Tue' as day_name_short,
        'dinsdag' as day_name_long_dutch,
        'Di' as day_name_short_german,
        1 as day_of_month,
        3 as day_of_week,
        2 as iso_day_of_week,
        336 as day_of_year,
        cast('{{ get_test_week_start_date()[1] }}' as date) as week_start_date,
        cast('{{ get_test_week_end_date()[1] }}' as date) as week_end_date,
        {{ get_test_week_of_year()[1] }} as week_of_year,
        cast('2020-11-30' as date) as iso_week_start_date,
        cast('2020-12-06' as date) as iso_week_end_date,
        49 as iso_week_of_year,
        '2020-W49' as iso_year_week,
        12 as month_number,
        'December' as month_name,
        'Dec' as month_name_short,
        'december' as month_name_dutch,
        'Dec' as month_name_short_german,
        1623076520 as unix_epoch,
        cast(
            '{{ get_test_timestamps()[0] }}' as {{ dbt.type_timestamp() }}
        ) as time_stamp,
        cast(
            '{{ get_test_timestamps()[1] }}' as {{ dbt.type_timestamp() }}
        ) as time_stamp_utc,
        cast('2021-06-07' as {{ dbt.type_timestamp() }}) as rounded_timestamp,
        cast('2021-06-08' as {{ dbt.type_timestamp() }}) as rounded_timestamp_utc,
        -- These columns are here to make sure these macros get run during testing:
        {{ dbt_date.last_month_number() }} as last_month_number,
        {{ dbt_date.last_month_name(short=False) }} as last_month_name,
        {{ dbt_date.last_month_name(short=True) }} as last_month_name_short,
        {{ dbt_date.next_month_number() }} as next_month_number,
        {{ dbt_date.next_month_name(short=False) }} as next_month_name,
        {{ dbt_date.next_month_name(short=True) }} as next_month_name_short,
        cast('{{ modules.datetime.date(1997, 9, 29) }}' as date) as datetime_date,
        cast(
            '{{ modules.datetime.datetime(1997, 9, 29, 6, 14, 0, tzinfo=modules.pytz.timezone(var("dbt_date:time_zone"))) }}'
            as {{ dbt.type_timestamp() }}
        ) as datetime_datetime

{%- endmacro %}

{% macro get_test_week_of_year() -%}
    {{
        return(
            adapter.dispatch("get_test_week_of_year", "dbt_date_integration_tests")()
        )
    }}
{%- endmacro %}

{% macro default__get_test_week_of_year() -%}
    {# weeks_of_year for '2020-11-29' and '2020-12-01', respectively #}
    {{ return([48, 48]) }}
{%- endmacro %}

{% macro snowflake__get_test_week_of_year() -%}
    {# weeks_of_year for '2020-11-29' and '2020-12-01', respectively #}
    {# Snowflake uses ISO year #}
    {{ return([48, 49]) }}
{%- endmacro %}

{% macro spark__get_test_week_of_year() -%}
    {# weeks_of_year for '2020-11-29' and '2020-12-01', respectively #}
    {# spark uses ISO year #}
    {{ return([48, 49]) }}
{%- endmacro %}

{% macro trino__get_test_week_of_year() -%}
    {# weeks_of_year for '2020-11-29' and '2020-12-01', respectively #}
    {# trino uses ISO year #}
    {{ return([48, 49]) }}
{%- endmacro %}


{% macro get_test_week_start_date() -%}
    {{
        return(
            adapter.dispatch(
                "get_test_week_start_date", "dbt_date_integration_tests"
            )()
        )
    }}
{%- endmacro %}

{% macro default__get_test_week_start_date() -%}
    {{ return(["2020-11-29", "2020-11-29"]) }}
{%- endmacro %}

{% macro spark__get_test_week_start_date() -%}
    {# spark does not support non-iso weeks #}
    {{ return(["2020-11-23", "2020-11-30"]) }}
{%- endmacro %}

{% macro trino__get_test_week_start_date() -%}
    {# trino does not support non-iso weeks #}
    {{ return(["2020-11-23", "2020-11-30"]) }}
{%- endmacro %}


{% macro get_test_week_end_date() -%}
    {{
        return(
            adapter.dispatch("get_test_week_end_date", "dbt_date_integration_tests")()
        )
    }}
{%- endmacro %}

{% macro default__get_test_week_end_date() -%}
    {{ return(["2020-12-05", "2020-12-05"]) }}
{%- endmacro %}

{% macro spark__get_test_week_end_date() -%}
    {# spark does not support non-iso weeks #}
    {{ return(["2020-11-29", "2020-12-06"]) }}
{%- endmacro %}

{% macro trino__get_test_week_end_date() -%}
    {# trino does not support non-iso weeks #}
    {{ return(["2020-11-29", "2020-12-06"]) }}
{%- endmacro %}


{% macro get_test_timestamps() -%}
    {{
        return(
            adapter.dispatch("get_test_timestamps", "dbt_date_integration_tests")()
        )
    }}
{%- endmacro %}

{% macro default__get_test_timestamps() -%}
    {{
        return(
            [
                "2021-06-07 07:35:20.000000 America/Los_Angeles",
                "2021-06-07 14:35:20.000000 UTC",
            ]
        )
    }}
{%- endmacro %}

{% macro bigquery__get_test_timestamps() -%}
    {{ return(["2021-06-07 07:35:20.000000", "2021-06-07 14:35:20.000000"]) }}
{%- endmacro %}

{% macro snowflake__get_test_timestamps() -%}
    {{
        return(
            ["2021-06-07 07:35:20.000000 -0700", "2021-06-07 14:35:20.000000 -0000"]
        )
    }}
{%- endmacro %}

{% macro duckdb__get_test_timestamps() -%}
    {{ return(["2021-06-07 07:35:20.000000", "2021-06-07 14:35:20.000000"]) }}
{%- endmacro %}

{% macro spark__get_test_timestamps() -%}
    {{ return(["2021-06-07 07:35:20.000000", "2021-06-07 14:35:20.000000"]) }}
{%- endmacro %}
