ARG PACKAGE_NAME
ARG REPO_NAME
ARG PYTHON_MAJOR_VERSION=3.11

ARG UNAME=worker
ARG USER_ID=1000
ARG GROUP_ID=1000

###############################################################################################
######################################   BASE IMAGE   #########################################
###############################################################################################

FROM python:$PYTHON_MAJOR_VERSION-slim AS base

ARG REPO_NAME
ARG PACKAGE_NAME

ARG UNAME
ARG USER_ID
ARG GROUP_ID

#git can be removed if is not planned to use Nextail libraries
RUN set -ex \
  && apt-get update \
  && apt-get install -y curl git libssl-dev gcc g++ libgomp1 wget zip \
  && rm -rf /var/lib/apt/lists/* \
  && pip --no-cache-dir install --upgrade pip

# Avoid pdm installation though pip in order to avoid conflicts when installing packages globally
# Ref: https://github.com/pdm-project/pdm/issues/1388
ARG PDM_VERSION=2.22.0
RUN curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/${PDM_VERSION}/install-pdm.py | python3 - --version=${PDM_VERSION} --path /usr/local

# create non-root user
RUN groupadd -g $GROUP_ID -o $UNAME
RUN useradd -m -u $USER_ID -g $GROUP_ID -o -s /bin/bash $UNAME

# create directories that are going to be used by the user
# for python packages
ENV PYPACKAGES=/usr/python
RUN mkdir -p $PYPACKAGES
RUN chown -R $USER_ID:$GROUP_ID $PYPACKAGES
# for dagster
ENV DAGSTER_HOME=/opt/dagster
RUN mkdir -p $DAGSTER_HOME
RUN chown -R $USER_ID:$GROUP_ID $DAGSTER_HOME
# for the repo
RUN mkdir -p /opt/$REPO_NAME
RUN chown -R $USER_ID:$GROUP_ID /opt/$REPO_NAME
# for the logs
RUN mkdir -p /var/logs
RUN chown -R $USER_ID:$GROUP_ID /var/logs

# set required environment vars from host
ARG COMMIT
ENV COMMIT=$COMMIT
ARG GITHUB_REPOSITORY
ENV GITHUB_REPOSITORY=$GITHUB_REPOSITORY

# from now on use local user
USER $USER_ID
WORKDIR /home/$UNAME

###############################################################################################
######################################   STAGE IMAGE   ########################################
###############################################################################################

FROM base AS stage

ARG USER_ID
ARG GROUP_ID
ARG PYTHON_MAJOR_VERSION

# set python env
WORKDIR $PYPACKAGES

# copy PDM files
COPY --chown=$USER_ID:$GROUP_ID ./pyproject.toml ./pdm.lock $PYPACKAGES/

# install dependencies
RUN pdm config python.use_venv false
RUN pdm install --prod --check --no-editable

# set python  env
ENV PYTHONPATH=$PYPACKAGES/__pypackages__/$PYTHON_MAJOR_VERSION/lib
ENV PATH=$PYPACKAGES/__pypackages__/$PYTHON_MAJOR_VERSION/bin/:$PATH

###############################################################################################
######################################   CLOUD IMAGE   ########################################
###############################################################################################

FROM stage AS cloud

ARG PACKAGE_NAME
ARG REPO_NAME

ARG USER_ID
ARG GROUP_ID

# form now on use repo folder as workdir
WORKDIR /opt/$REPO_NAME

# copy project
COPY --chown=$USER_ID:$GROUP_ID ./$PACKAGE_NAME/ /opt/$REPO_NAME/$PACKAGE_NAME/
COPY --chown=$USER_ID:$GROUP_ID ./scripts /opt/$REPO_NAME/scripts/
COPY --chown=$USER_ID:$GROUP_ID ./dbt_project /opt/$REPO_NAME/$PACKAGE_NAME/dbt_project
###############################################################################################
####################################    LOCAL IMAGE     #######################################
###############################################################################################

FROM base AS local

ARG REPO_NAME
ARG PACKAGE_NAME
ARG PYTHON_MAJOR_VERSION

ARG USER_ID
ARG GROUP_ID

#set venv
WORKDIR $PYPACKAGES

ENV NX_ENVIRONMENT=test

# set python  env
ENV PYTHONPATH=/opt/$REPO_NAME/__pypackages__/$PYTHON_MAJOR_VERSION/lib
ENV PATH=/opt/$REPO_NAME/__pypackages__/$PYTHON_MAJOR_VERSION/bin/:$PATH

#copy project
COPY --chown=$USER_ID:$GROUP_ID . /opt/$REPO_NAME

###############################################################################################
####################################    PDM IMAGE     #########################################
###############################################################################################

FROM local AS pdm

# set pdm env
RUN pdm config python.use_venv false

###############################################################################################
####################################    LINT IMAGE     ########################################
###############################################################################################

FROM pdm AS lint

# set pdm env
RUN pdm install --dev

###############################################################################################
####################################    DEV IMAGE     #########################################
###############################################################################################

FROM local AS dev

# set pdm env
RUN pdm config python.use_venv false

###############################################################################################
####################################   TEST IMAGE     #########################################
###############################################################################################

FROM stage AS test

ARG REPO_NAME
ARG PACKAGE_NAME

ARG USER_ID
ARG GROUP_ID

# only root can install packages
USER root
RUN apt update && apt install -y make

# from now on use local user
USER $USER_ID
# form now on use dagster folder as workdir
WORKDIR $DAGSTER_HOME

ENV NX_ENVIRONMENT=test

# install dev dependencies
WORKDIR $PYPACKAGES
RUN pdm install --dev

# copy project
COPY --chown=$USER_ID:$GROUP_ID ./$PACKAGE_NAME/ /opt/$REPO_NAME/$PACKAGE_NAME/
COPY --chown=$USER_ID:$GROUP_ID ./tests /opt/$REPO_NAME/tests
COPY --chown=$USER_ID:$GROUP_ID .pre-commit-config.yaml .yamllint /opt/$REPO_NAME/

# set workdir for tests
WORKDIR /opt/$REPO_NAME

###############################################################################################
####################################   SERVICE IMAGE     ######################################
###############################################################################################

FROM stage AS srv

ARG USER_ID
ARG GROUP_ID

ENV NX_ENVIRONMENT=dev

# install dev dependencies
WORKDIR $PYPACKAGES
RUN pdm install --check -G dev

WORKDIR $DAGSTER_HOME
COPY --chown=$USER_ID:$GROUP_ID ./docker/dagster/dagster.yaml ./docker/dagster/workspace.yaml $DAGSTER_HOME/
