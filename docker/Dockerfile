ARG PACKAGE_NAME
ARG REPO_NAME
ARG PYTHON_MAJOR_VERSION=3.9

###############################################################################################
######################################   BASE IMAGE   #########################################
###############################################################################################

FROM python:$PYTHON_MAJOR_VERSION-slim AS base

#git can be removed if is not planned to use Nextail libraries
RUN set -ex \
    && apt-get update \
    && apt-get install -y curl git \
    && rm -rf /var/lib/apt/lists/*

# Avoid pdm installation though pip in order to avoid conflicts when installing packages globally
# Ref: https://github.com/pdm-project/pdm/issues/1388
ARG PDM_VERSION=2.12.3
RUN curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/${PDM_VERSION}/install-pdm.py | python3 - --version=${PDM_VERSION} --path /usr/local

# set required environment vars from host
ARG GITHUB_PIP_TOKEN
ENV GITHUB_PIP_TOKEN=$GITHUB_PIP_TOKEN
ARG COMMIT
ENV COMMIT=$COMMIT
ARG GITHUB_REPOSITORY
ENV GITHUB_REPOSITORY=$GITHUB_REPOSITORY

###############################################################################################
######################################   STAGE IMAGE   ########################################
###############################################################################################

FROM base AS stage

ARG PYTHON_MAJOR_VERSION

# set python env
ENV PYPACKAGES=/usr/python
RUN mkdir -p $PYPACKAGES
WORKDIR $PYPACKAGES

# copy PDM files
COPY ./pyproject.toml ./pdm.lock $PYPACKAGES/

# install dependencies
RUN pdm config python.use_venv false
RUN pdm install --prod --check --no-editable

# set python  env
ENV PYTHONPATH=$PYPACKAGES/__pypackages__/$PYTHON_MAJOR_VERSION/lib
ENV PATH=$PYPACKAGES/__pypackages__/$PYTHON_MAJOR_VERSION/bin/:$PATH

# set dagster env & workdir
ENV DAGSTER_HOME=/opt/dagster
RUN mkdir -p $DAGSTER_HOME
WORKDIR $DAGSTER_HOME

###############################################################################################
######################################   CLOUD IMAGE   ########################################
###############################################################################################

FROM stage AS cloud

ARG PACKAGE_NAME
ARG REPO_NAME
ARG ENVIRONMENT
ENV NX_ENVIRONMENT=$ENVIRONMENT

# copy project
COPY ./$PACKAGE_NAME/ /opt/$REPO_NAME/$PACKAGE_NAME/

###############################################################################################
####################################    LOCAL IMAGE     #######################################
###############################################################################################

FROM base AS local

ARG REPO_NAME
ARG PYTHON_MAJOR_VERSION

#set venv
WORKDIR $PYPACKAGES

ENV NX_ENVIRONMENT=test

# set python env
ENV DAGSTER_DEV=/opt/$REPO_NAME
RUN mkdir -p $DAGSTER_DEV
WORKDIR $DAGSTER_DEV

# set python  env
ENV PYTHONPATH=$DAGSTER_DEV/__pypackages__/$PYTHON_MAJOR_VERSION/lib
ENV PATH=$DAGSTER_DEV/__pypackages__/$PYTHON_MAJOR_VERSION/bin/:$PATH

#copy project
COPY . /opt/$REPO_NAME/

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

ARG UNAME=local-dev
ARG USER_ID=1000
ARG GROUP_ID=1000

# set user and group for dev
RUN groupadd -g $GROUP_ID -o $UNAME
RUN useradd -m -u $USER_ID -g $GROUP_ID -o -s /bin/bash $UNAME
USER $UNAME

# set pdm env
RUN pdm config python.use_venv false

###############################################################################################
####################################   TEST IMAGE     #########################################
###############################################################################################

FROM stage AS test

ARG REPO_NAME

RUN apt update && apt install -y make
ENV NX_ENVIRONMENT=test

# install dev dependencies
WORKDIR $PYPACKAGES
RUN pdm install --dev

# copy project
COPY ./$PACKAGE_NAME/ /opt/$REPO_NAME/$PACKAGE_NAME/
COPY ./tests /opt/$REPO_NAME/tests
COPY .pre-commit-config.yaml .yamllint /opt/$REPO_NAME/

# set workdir for tests
WORKDIR /opt/$REPO_NAME

###############################################################################################
####################################   SERVICE IMAGE     ######################################
###############################################################################################

FROM stage AS srv

ENV NX_ENVIRONMENT=dev

# install dev dependencies
WORKDIR $PYPACKAGES
RUN pdm install --check -G dev

WORKDIR $DAGSTER_HOME
COPY ./docker/dagster/dagster.yaml ./docker/dagster/workspace.yaml $DAGSTER_HOME/
