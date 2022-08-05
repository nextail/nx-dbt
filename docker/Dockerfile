###############################################################################################
######################################   BASE IMAGE   #########################################
###############################################################################################

FROM python:3.9-slim AS base

# install PDM
RUN pip install -U pip setuptools wheel
RUN pip install pdm

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
RUN pdm install --prod --no-lock --no-editable

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
RUN pdm install --dev --no-lock

# copy project
COPY ./dagster/tests $DAGSTER_HOME/tests

# set workdir for tests
WORKDIR $DAGSTER_HOME/tests