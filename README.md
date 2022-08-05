# dagster-template

Welcome to your new Dagster repository.

### Contents

| **Name**                     | **Description**                                                                       |
| ---------------------------- | ------------------------------------------------------------------------------------- |
| `.circleci/`                 | workflows of Circleci                                                                 |
| `.github/`                   | issue and pull request templates                                                      |
| `dagster/`                   | contains the code for your Dagster repositories                                       |
| `docker/`                    | A Python directory that contains code for your Dagster repository                     |
| `scripts/`                   | Utils for makefile                                                                    |
| `CHANGELOG.md`               | Log of all notable changes made for this code repository                              |
| `Makefile`                   | Automating software building procedure                                                |
| `README.md`                  | A description and guide for this code repository                                      |

### Makefile

| **Action**                | **Description**                                                         |
| ------------------------- | ----------------------------------------------------------------------- |
| **help**                  | show this help                                                          |
| **dev-deps**              | test if the dependencies we need to run this Makefile are installed     |
| **test**                  | pytest                                                                  |
| **create-env**            | create .env file                                                        |
| **start-dev**             | start the docker environment in background                              |
| **shell**                 | start the docker environment in background with shell                   |
| **start-dev-nocache**     | start the docker environment in background without cache on build       |
| **stop-dev**              | stop the the docker environment in background                           |
| **dev-clean**             | clean all the created containers                                        |
| **dev-clean-full**        | clean all the created containers and their data                         |
| **clean**                 | remove all build, test, coverage and Python artifacts                   |
| **clean-packages**        | remove build packages                                                   |
| **clean-pyc**             | remove Python pyc files                                                 |
| **clean-test**            | remove test and coverage artifacts                                      |

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

#### 2.1.1 Start environment

To start the development environment:
```bash
make start-dev
```

Navigate to http://127.0.0.0:3000 in your web browser.
Go to Launchpad tab. On this tab you will be able to edit job configuration. 
On the bottom right it is the "Lunch Run" execution button.

#### 2.1.2 Shell

If you want to start a shell with pdm installed, ready to interact with the source projects:
```bash
make shell
```
where workdir is: `/usr/src` with folders:
- `dagster`: project
- `scripts`: utils

If you want to install dev-dependencies run the utility:
```bash
./scripts/pdm-config.sh
```

#### 2.1.3 Test

For testing (without shell):
```bash
make test
```

As you create Dagster ops and graphs, add tests in `dagster/tests/` to check that your
code behaves as desired and does not break over time.

For hints on how to write tests for ops and graphs,
[see the documentation tutorial of Testing in Dagster](https://docs.dagster.io/tutorial/testable).
### 2.2. Cloud

We have two operating environments: sandbox and production.

CI/CD Integration with CircleCI Orb.

#### 2.2.1 Environments

- **Nextail Cloud**: [Link](https://nextail.dagster.cloud/)
  - Workspaces:
    - **Sandbox**: [Link](https://nextail.dagster.cloud/sandbox)
    - **Prod**: [Link](https://nextail.dagster.cloud/prod)

#### 2.2.2 Orb

The Circleci workflow lets you automatically update Dagster Cloud code locations when pipeline code is updated. The workflows builds a Docker image, pushes it to a Docker Hub repository, and uses the Dagster Cloud CLI to tell your agent to add the built image to your workspace. 

The workflows included in this template already has this worflow setup for you:

| **Workflow**                  | **Branch**   | **Description**
| ----------------------------- | ------------ | ---------------------------------------------------------------------------------------------------- |
| **unit-test**                 | all          | Execute make test (developer can change the functionality of make test)                             |
| **build-and-deploy-sandbox**  | sandbox      | Build docker image from Dockerfile, push image to DockerHub and deploy project in Dagster Sandbox    |
| **build-and-deploy-prod**     | main         | Build docker image from Dockerfile, push image to DockerHub and deploy project in Dagster Production |

[More info](https://circleci.com/developer/orbs/orb/nextail/dagster-pipelines-orb)