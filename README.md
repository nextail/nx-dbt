# Dagster Nextail Template

![dagster-in-nextail](images/dagster-in-nextail.png)

In order to make it easier to start the development in Dagster this template is provided.

This template will give us:

- A local development environment based on docker and docker-compose
- CI/CD integration with Dagster Cloud
- Examples of simple and test pipelines

## Contents

| **Name**                     | **Description**                                                                       |
| ---------------------------- | ------------------------------------------------------------------------------------- |
| `.circleci/`                 | workflows of Circleci                                                                 |
| `.github/`                   | issue and pull request templates                                                      |
| `.platform/`                 | Helm chart configuration for our Service Account and Service Provider                 |
| `.vscode/`                   | Visual Studio Code custom configurations for debugging                                |
| `dagster_template/`          | python package of your repository,it will change its name once you launch the update  |
| `docker/`                    | definition of containers on which we will develop                                     |
| `images/`                    | images for the documentatio                                                           |
| `scripts/`                   | Utils for makefile                                                                    |
| `tests/`                     | python tests for your package                                                         |
| `Makefile`                   | Automating software building procedure                                                |
| `pyproject.toml`             | This file contains requirements, which are used by pip to build the package           |
| `pdm.lock`                   | Dependencies and sub-dependencies resolved properly form pyproject.toml               |
| `README.md`                  | A description and guide for this code repository                                      |

## Makefile

| **Action**                | **Description**                                                         |
| ------------------------- | ----------------------------------------------------------------------- |
| **help**                  | show this help                                                          |
| **dev-deps**              | test if the dependencies we need to run this Makefile are installed     |
| **update**                | This script updates all references to dagster-template                  |
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
| **pdm-lock**              | regenerate the pdm file                                                 |

## 0. Template

### Create the project

:warning: **Important: User that creates the Github repository should be the same one that will later configure the project in CircleCI**

To start, create a new repository and reference this template to make a copy:
![Repo-for-template](images/repository-from-template.png)

Then run:

```bash
make update
```

This script updates all references to dagster-template by replacing them with the name of your repository and creates a module with the name of your github repository and will refactor the sample code.

### Set up Dockerhub repository for your service

File a Request ticket in [ServiceDesk](https://nextail.atlassian.net/servicedesk/customer/portals) asking for a [new dockerhub repository](https://cloud.docker.com/u/nextail/repository/list) to host your Docker images. Remember to include the name of the DockerHub repository you want. This is a manual process, since appropriate permissions must be set for developers and bots.

### Set up your project in CI

Configure the project in CircleCI. Pipelines are configured in the default folder `.circleci`:

- Search your project "https://app.circleci.com/projects/project-dashboard/github/nextail/"
- Push Set Up Project: ![Set up project](images/circleci.png)
- Set the config.yml file: ![Set config file](images/circleci-2.png)

[More Info](https://app.circleci.com/projects/project-dashboard/github/nextail/)

## 1. Requirements

- Docker
- Python ≥3.9
- [PDM](https://pdm.fming.dev/latest/#installation): using containerization, install pdm locally is not necessary.(<https://pdm.fming.dev/latest/usage/hooks/#dependencies-management>)
- [pre-commit](https://pre-commit.com/#install): using containerization, install pre-commit locally is not necessary.

## 2. Scenarios

1. Development
2. Cloud

### 2.1. Development

Include:

- Postgres 11
- Dagster Daemon
- Dagit

Dagster Daemon and Dagit have your package folder as a docker volume.

The `dagster` module contains the code for your Dagster repository. A repository is a collection of software-defined assets, jobs, schedules, and sensors. Repositories are loaded as a unit by the Dagster CLI, Dagit and the Dagster Daemon. he repository specifies a list of items, each of which can be a AssetsDefinition, JobDefinition, ScheduleDefinition, or SensorDefinition. If you include a schedule or sensor, the job it targets will be automatically also included on the repository.

#### 2.1.1 Start environment

To start the development environment:

```bash
make start-dev
```

<https://user-images.githubusercontent.com/26308855/192459452-a7eb3a7a-1b03-49e6-b901-f0b1cc41d0fc.mov>

Navigate to <http://127.0.0.0:3000> in your web browser.
Go to Launchpad tab. On this tab you will be able to edit job configuration.
On the bottom right it is the "Lunch Run" execution button.

<https://user-images.githubusercontent.com/26308855/192459512-d8e9141d-0443-459a-a89e-73a0189517a0.mov>

#### 2.1.2 Shell

If you want to start a shell with pdm installed, ready to interact with the source projects:

```bash
make shell
```

where workdir is: `/opt/dagster-poc` with folders:

- `dagster`: project
- `scripts`: utils

<https://user-images.githubusercontent.com/26308855/192459555-1df66474-f8e8-41e1-a829-124591a77c9b.mov>

Then you can run your tests with pytest:

```bash
pytest
```

<https://user-images.githubusercontent.com/26308855/193572680-99fcdf55-c055-4633-a76f-dba838b3da09.mov>

#### 2.1.3 Test

For testing (without shell):

```bash
make test
```

<https://user-images.githubusercontent.com/26308855/192459713-56aec8e3-9804-49cb-9464-e9b75f00c311.mp4>

As you create Dagster ops and graphs, add tests in `tests/dagster` to check that your
code behaves as desired and does not break over time.

For hints on how to write tests for ops and graphs,
[See the documentation tutorial of Testing in Dagster](https://docs.dagster.io/tutorial/testable)

#### 2.1.4 Linting

For lint the repository:

```bash
make lint
```

For linting without apply changes:

```bash
make lint-check
```

#### 2.1.5 Debug with vscode

One of the great things in Visual Studio Code is [debugging support](https://code.visualstudio.com/docs/editor/debugging). Set breakpoints, step-in, inspect variables and more. The template is prepared to use this utility. Within the run and debug menu you can select dagit:localhost or dagster-daemon:localhost to start your debug.

![debug-with-vscode](images/debug.png)

### 2.2. Cloud

We have two operating environments: sandbox and production.

CI/CD Integration with CircleCI Orb.

#### 2.2.0 Requirements

- Request Docker image on Docker Hub with the same name as your repository to #squad-platform
- Configure the project in CircleCI. Pipelines are configured in the default folder .circleci

#### 2.2.1 Environments

- **Nextail Cloud**: [Link](https://nextail.dagster.cloud/)
  - Workspaces:
    - **Sandbox**: [Link](https://nextail.dagster.cloud/sandbox)
    - **Prod**: [Link](https://nextail.dagster.cloud/prod)

#### 2.2.2 Orb

The Circleci workflow lets you automatically update Dagster Cloud code locations when pipeline code is updated. The workflows builds a Docker image, pushes it to a Docker Hub repository, and uses the Dagster Cloud CLI to tell your agent to add the built image to your workspace.

[More info](https://circleci.com/developer/orbs/orb/nextail/dagster-pipelines-orb)

#### 2.2.3 Permissions

The template provided for development provides an integration with Dagster Cloud that omits any type of requirement of a service account for the deployment by default.

For default the executions we use an Amazon Service Account "user-cloud-dagster-cloud-agent" as default, which has basic permissions for the execution of jobs such as:

- **Amazon S3**: The default Service Account has permissions over the following paths:
  - For **evo** pipelines (should be everything):
    - SANDBOX:
      - nextail-dev-evo/dagster/{{your_path}}:

        ``` yml
        s3_bucket: nextail-{{tenant}}-evo
        s3_prefix: env-sandbox/{{tenant}}/dagster/{{your_path}}
        ```

    - PRODUCTION:
      - nextail-{{tenant}}-evo/dagster/{{your_path}}:

          ``` yml
          s3_bucket: nextail-{{tenant}}-evo
          s3_prefix: dagster/{{your_path}}
          ```

  - For **no evo** pipelines:
    - SANDBOX:
      - nextail-dev/dagster/{{your_path}}:

          ``` yml
          s3_bucket: nextail-dev
          s3_prefix: env-sandbox/{{tenant}}/dagster/{{your_path}}
          ```

    - PRODUCTION:
      - nextail-{{tenant}}/dagster/{{your_path}}:

          ```yml
          s3_bucket: nextail-{{tenant}}
          s3_prefix: dagster/{{your_path}}
          ```

- **Amazon Secrets Manager**: access to Secrets containing the following tags
  - "scope-dagster": "true"
  - "environment": "${environment}" (where environment could be sandbox or production)

- **K8s**: running jobs on Kubernetes in the environment that corresponds to it.

#### 2.2.4 Custom Service Account

If the execution of your pipelines you need more permissions or change any of the existing ones, it will be necessary to create a specific Amazon Service Account for your repository following [this guide](https://engineering-portal-sandbox.nextail.co/docs/platform-architecture/operations/secrets/Howto_for_developers/#table-of-contents). You will create a new AWS role which will contain the permissions of the app to interact with AWS. By default, your app will only be able to interact with AWS Secrets Manager, if you need additional permissions to access other AWS services like S3, Lambda... ask [platform](https://nextail-labs.slack.com/archives/CLZJ97WCC)

##### Step 1: Configure the creation of Service Account and Service Provider

Configure the file `.platform/charts/{{your_repository}}/values.yaml`:

1. Change serviceAccount create to true
2. Set your envVars and AWS keys to map your secrets into app environment

```yaml
# Kubernetes Service Account
# By default it will be false and a default dagster service account will be used.
# In case of create: true, the circleci pipeline must also be configured setting the property custom_service_account: true.
serviceAccount:
  create: true

# envVar: is the name of the environment variable that will be exposed in your application container.
# key: refers to the key inside your AWS Secrets Manager secret.
envFromSecretsManager:
  - envVar: ENV_NAME
    key: secret_key
```

##### Step 2: Set our Custom Service Account into our Dagster Project

The last step will be to modify in the file `.circleci/config.yml` the parameter **custom_service_account** in the line 9 `default: false` to `default: true`.

```yaml
version: 2.1

orbs:
  dagster-pipelines-orb: nextail/dagster-pipelines-orb@1.2.3

parameters:
  custom_service_account:
    type: boolean
    default: true
    description: "We use this parameter to define if our project uses its own service account (true) or by default (false)."
```
