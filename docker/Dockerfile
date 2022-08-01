###############################################################################################
######################################   BASE IMAGE   #########################################
###############################################################################################

FROM python:3.9-slim AS base

# set python env
ENV PYPACKAGES=/usr/python
RUN mkdir -p $PYPACKAGES
WORKDIR $PYPACKAGES

# install PDM
RUN pip install -U pip setuptools wheel
RUN pip install pdm

# copy PDM files
COPY pyproject.toml pdm.lock $PYPACKAGES/

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

FROM base AS cloud
# copy project
COPY ./dagster/src $DAGSTER_HOME/src
COPY ./dagster/repository.py $DAGSTER_HOME/

###############################################################################################
####################################    DEV IMAGE     #########################################
###############################################################################################

FROM base AS dev
WORKDIR $PYPACKAGES
RUN pdm install --dev  --no-lock
WORKDIR $DAGSTER_HOME

###############################################################################################
####################################   TEST IMAGE     #########################################
###############################################################################################

FROM dev AS test
COPY ./dagster $DAGSTER_HOME