from dagster import op


@op(
    description="""
    An op definition. This example op outputs a single string.

    For more hints about writing Dagster ops, see our documentation overview on Ops:
    https://docs.dagster.io/concepts/ops-jobs-graphs/ops
    """
)
def hello():
    return "Hello, Dagster!"
