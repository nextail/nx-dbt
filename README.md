# dagster-poc

Welcome to your new Dagster repository.

### Contents

| Name                     | Description                                                                       |
| ------------------------ | --------------------------------------------------------------------------------- |
| `.github/`               | workflows, templates, and some other files specific to the project                |
| `dagster/`               | A Python directory that contains code for your Dagster repository                 |
| `docker/`                | A Python directory that contains code for your Dagster repository                 |
| `CHANGELOG.md`           | Log of all notable changes made for this code repository                          |
| `Makefile`               | Automating software building procedure                                            |
| `pyproject.toml`         | Dependencies file in toml managed by [PDM](https://github.com/pdm-project/pdm)    |
| `README.md`              | A description and guide for this code repository                                  |

### Makefile

| Action                | Description                                                         |
| --------------------- | ------------------------------------------------------------------- |
| **help**              | show this help                                                      |
| **dev-deps**          | test if the dependencies we need to run this Makefile are installed |
| **test**              | pytest                                                              |
| **start-dev**         | start the docker environment in background                          |
| **start-dev-nocache** | start the docker environment in background without cache on build   |
| **stop-dev**          | stop the the docker environment in background                       |
| **dev-clean**         | clean all the created containers                                    |
| **dev-clean-full**    | clean all the created containers and their data                     |
| **clean**             | remove all build, test, coverage and Python artifacts               |
| **clean-build**       | remove build artifacts                                              |
| **clean-pyc**         | remove Python file artifacts                                        |
| **clean-test**        | remove test and coverage artifacts                                  |

## 1. Requirements

- Docker
- Python ≥3.9
- [PDM](https://pdm.fming.dev/latest/#installation): using containerization, installing pdm locally is not necessary.(https://pdm.fming.dev/latest/usage/hooks/#dependencies-management)

## 2. Scenarios

1. Development
2. Cloud
### 2.1. Development

Include:
- Postgres 11
- Dagster Daemon
- Dagit

Dagster Daemon and Dagit have `dagster` folder as a docker volume.

The folder `dagster/src/` contains the code for your Dagster repository. A repository is a collection of software-defined assets, jobs, schedules, and sensors. Repositories are loaded as a unit by the Dagster CLI, Dagit and the Dagster Daemon. he repository specifies a list of items, each of which can be a AssetsDefinition, JobDefinition, ScheduleDefinition, or SensorDefinition. If you include a schedule or sensor, the job it targets will be automatically also included on the repository.

To start the development environment:
```bash
make start-dev
```

Navigate to http://127.0.0.0:3000 in your web browser.
Go to Launchpad tab. On this tab you will be able to edit job configuration. 
On the bottom right it is the "Lunch Run" execution button.

```bash
make test
```

As you create Dagster ops and graphs, add tests in `dagster/tests/` to check that your
code behaves as desired and does not break over time.

For hints on how to write tests for ops and graphs,
[see the documentation tutorial of Testing in Dagster](https://docs.dagster.io/tutorial/testable).
### 2.2. Cloud

[In progress]()


