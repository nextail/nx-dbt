#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
rm -fr ${SCRIPTPATH}/../dagster/build/
rm -fr ${SCRIPTPATH}/../dagster/dist/
rm -fr ${SCRIPTPATH}/../dagster/.eggs/
find ${SCRIPTPATH}/.. -name '*.egg-info' -exec rm -fr {} +
find ${SCRIPTPATH}/.. -name '*.egg' -exec rm -f {} +
find ${SCRIPTPATH}/.. -name '*.pyc' -exec rm -f {} +
find ${SCRIPTPATH}/.. -name '*.pyo' -exec rm -f {} +
find ${SCRIPTPATH}/.. -name '*~' -exec rm -f {} +
find ${SCRIPTPATH}/.. -name '__pycache__' -exec rm -fr {} +