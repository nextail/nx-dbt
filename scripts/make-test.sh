#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SERVICE=$(basename `git rev-parse --show-toplevel`)
IMAGE="nextail/${SERVICE}_test"
TARGET="test"
docker_run(){
    echo 
    echo "------------------------------"
    echo "Run tests"
    echo "------------------------------"
    echo
    docker run --rm -it --entrypoint pytest  "${IMAGE}"
}

docker_build(){
    docker build --no-cache --target ${TARGET} -t "${IMAGE}" -f ${SCRIPTPATH}/../docker/Dockerfile ${SCRIPTPATH}/.. --build-arg GITHUB_PIP_TOKEN=${GITHUB_PIP_TOKEN}
}

docker_build
docker_run