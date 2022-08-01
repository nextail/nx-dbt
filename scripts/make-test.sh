#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
IMAGE="dagster_test"
TARGET="test"
docker_run(){
    echo 
    echo "------------------------------"
    echo "Run tests"
    echo "------------------------------"
    echo
    docker run --rm -it -v ${SCRIPTPATH}/../dagster:/opt/dagster/ --entrypoint pytest  ${IMAGE}
}

docker_build(){
    docker build --target ${TARGET} -t ${IMAGE} -f ${SCRIPTPATH}/../docker/Dockerfile ${SCRIPTPATH}/..
}

docker_build
docker_run