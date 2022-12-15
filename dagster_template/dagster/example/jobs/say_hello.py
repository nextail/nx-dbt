from dagster import MetadataValue, job

from dagster_template.dagster.example.ops.hello import hello


@job(
    metadata={
        "owner": "nextail-squad",  # will be converted to MetadataValue.text
        "tenant": "nextail-tenant",  # will be converted to MetadataValue.text
        "domain": "nextail-domain",  # will be converted to MetadataValue.text
        "repository": MetadataValue.url("https://github.com/nextail/my-repo/"),
        "procedures": MetadataValue.url("https://engineering-portal-sandbox.nextail.co/"),
    },
    tags={"owner": "nextail-squad", "tenant": "nextail-tenant", "domain": "nextail-domain"},
)
def say_hello_job():
    """
    A job definition. This example job has a single op.

    For more hints on writing Dagster jobs, see our documentation overview on Jobs:
    https://docs.dagster.io/concepts/ops-jobs-graphs/jobs-graphs
    """
    hello()
