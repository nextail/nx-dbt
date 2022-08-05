#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
find ${SCRIPTPATH}/.. -name '.pytest_cache' -exec rm -fr {} +