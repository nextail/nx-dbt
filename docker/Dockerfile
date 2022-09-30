###############################################################################################
######################################   BASE IMAGE   #########################################
###############################################################################################

FROM python:3.9-slim AS base

RUN set -ex \
    && apt-get update \
    && apt-get install -y curl git #git can be removed if is not planned to use Nextail libraries.

# install PDM
RUN pip install -U pip setuptools wheel

# Avoid pdm installation though pip in order to avoid conflicts when installing packages globally
# Ref: https://github.com/pdm-project/pdm/issues/1388
RUN curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/2.1.4/install-pdm.py | python3 - --version=2.1.4
ENV PATH=/root/.local/bin:${PATH}

# set required environment vars from host
# These can be removed if is not planned to use Nextail libraries.
ARG GITHUB_PIP_TOKEN
ENV GITHUB_PIP_TOKEN=$GITHUB_PIP_TOKEN

###############################################################################################
######################################   STAGE IMAGE   ########################################
###############################################################################################

FROM base AS stage

# set python env
ENV PYPACKAGES=/usr/python
RUN mkdir -p $PYPACKAGES
WORKDIR $PYPACKAGES

# copy PDM files
COPY ./dagster/pyproject.toml ./dagster/pdm.lock $PYPACKAGES/

# install dependencies
RUN pdm config python.use_venv false
RUN pdm install --prod --check --no-editable

# set python  env
ENV PYTHONPATH=$PYPACKAGES/__pypackages__/3.9/lib
ENV PATH=$PYPACKAGES/__pypackages__/3.9/bin/:$PATH

# set dagster env & workdir
ENV DAGSTER_HOME=/opt/dagster
RUN mkdir -p $DAGSTER_HOME
WORKDIR $DAGSTER_HOME

###############################################################################################
######################################   CLOUD IMAGE   ########################################
###############################################################################################

FROM stage AS cloud

# copy project
COPY ./dagster/src $DAGSTER_HOME/src
COPY ./dagster/repository.py $DAGSTER_HOME/

###############################################################################################
####################################    DEV IMAGE     #########################################
###############################################################################################

FROM base AS dev

ARG UNAME=local-dev
ARG USER_ID=1000
ARG GROUP_ID=1000

# set python env
ENV DAGSTER_DEV=/usr/src/dagster
RUN mkdir -p $DAGSTER_DEV
WORKDIR $DAGSTER_DEV

# set python  env
ENV PYTHONPATH=$DAGSTER_DEV/__pypackages__/3.9/lib
ENV PATH=$DAGSTER_DEV/__pypackages__/3.9/bin/:$PATH

RUN groupadd -g $GROUP_ID -o $UNAME
RUN useradd -m -u $USER_ID -g $GROUP_ID -o -s /bin/bash $UNAME
USER $UNAME

###############################################################################################
####################################   TEST IMAGE     #########################################
###############################################################################################

FROM cloud AS test

# install dev dependencies
WORKDIR $PYPACKAGES
RUN pdm install --check -G test

# copy project
COPY ./dagster/tests $DAGSTER_HOME/tests

# set workdir for tests
WORKDIR $DAGSTER_HOME/tests
