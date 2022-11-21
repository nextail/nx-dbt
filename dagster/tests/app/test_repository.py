from repository import app

def test_repository_loads_all_definitions():
    """
    Asserts that the repository can load all definitions (jobs, assets, schedules, etc)
    without errors.
    """

    app.load_all_definitions()