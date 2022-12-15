from dagster_template.dagster.repository import example


def test_repository_loads_all_definitions():
    """
    Asserts that the repository can load all definitions (jobs, assets, schedules, etc)
    without errors.
    """

    example.load_all_definitions()
