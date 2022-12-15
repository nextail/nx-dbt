#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
find ${SCRIPTPATH}/.. -name '__pypackages__' -exec rm -fr {} +
find ${SCRIPTPATH}/.. -name '.pdm.toml' -exec rm -fr {} +
find ${SCRIPTPATH}/.. -name '.venv' -exec rm -fr {} +
