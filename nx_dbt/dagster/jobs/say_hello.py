from dagster import MetadataValue, job

from nx_dbt.dagster.ops.hello import hello


@job(
    name="_say_hello_job",
    metadata={
        "owner": "nextail-squad",  # will be converted to MetadataValue.text
        "tenant": "nextail-tenant",  # will be converted to MetadataValue.text
        "domain": "nextail-domain",  # will be converted to MetadataValue.text
        "repository": MetadataValue.url("https://github.com/nextail/dagster-template/"),
        "procedures": MetadataValue.url(
            "https://engineering-portal.nextail.co/docs/platform-architecture/for_developers/orchestration/dagster/"
        ),
    },
    tags={
        "dagster-k8s/config": {
            "pod_template_spec_metadata": {
                "labels": {"client": "client-name", "module": "module-name", "operation": "module-operation"}
            },
        },
        "owner": "nextail-squad",
        "tenant": "nextail-tenant",
        "domain": "nextail-domain",
        "version": "v0.0.1",
    },
    description="""
    A job definition. This example job has a single op.

    For more hints on writing Dagster jobs, see our documentation overview on Jobs:
    https://docs.dagster.io/concepts/ops-jobs-graphs/jobs-graphs
    """,
)
def say_hello_job():
    hello()
