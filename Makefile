.PHONY = help dev-deps test create-env start-dev shell start-dev-nocache stop-dev dev-clean dev-clean-full clean clean-packages clean-pyc clean-test pdm-lock
MAKEFLAGS += --warn-undefined-variables

#SERVICE_NAME := $(shell basename `git rev-parse --show-toplevel`)
SERVICE_NAME := dagster_template

# Shell to use for running scripts
SHELL := $(shell which bash)
# Get docker path or an empty string
DOCKER := $(shell command -v docker)
# Get docker-compose path or an empty string
DOCKER_COMPOSE := $(shell command -v docker-compose)
# Get current path
MKFILE_PATH := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
# Get OS
OSTYPE := $(shell uname)

# Export local user & group
export UID := $(shell id -u)
export GID := $(shell id -g)

# Setup msg colors
NOFORMAT := \033[0m
RED := \033[0;31m
GREEN := \033[0;32m
ORANGE := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
YELLOW := \033[1;33m

## help              : show this help
help: 
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

## dev-deps          : test if the dependencies we need to run this Makefile are installed
dev-deps:
ifndef DOCKER
	@echo -e "${RED}Docker is not available${NOFORMAT}. Please install docker"
	@exit 1
endif
ifndef DOCKER_COMPOSE
	@echo -e "${RED}docker-compose is not available${NOFORMAT}. Please install docker-compose"
	@exit 1
endif

## test              : pytest
test: dev-deps
	@bash scripts/make-test.sh

## create-env        : create .env file
create-env: 
	@echo "SERVICE_NAME=${SERVICE_NAME}" > ${MKFILE_PATH}/docker/dagster/.env
	
## start-dev         : start the docker environment in background
start-dev: create-env
	@cd ${MKFILE_PATH}/docker/dagster && ${DOCKER_COMPOSE} up --build -d

## shell             : start the docker environment in background with shell
shell: start-dev
	@echo \
	&& DOCKER_BUILDKIT=1 \
	&& ${DOCKER} build --target dev -t nextail/${SERVICE_NAME}_dev \
		--build-arg UNAME=local-dev \
		--build-arg USER_ID=${UID} \
		--build-arg GROUP_ID=${GID} \
		--build-arg GITHUB_PIP_TOKEN=${GITHUB_PIP_TOKEN} \
		--build-arg SERVICE_NAME=${SERVICE_NAME} \
		-f ${MKFILE_PATH}/docker/Dockerfile ${MKFILE_PATH} \
	&& echo \
	&& echo -e "${BLUE}Dockerized ${NOFORMAT} shell ready to interact with the project." \
	&& echo -e "Execute ${CYAN}'exit'${NOFORMAT} to close and remove the container.\n" \
	&& ${DOCKER} run --rm -it --network=nxnet \
        --hostname dagster-shell \
		--user local-dev:local-dev \
        -v ${MKFILE_PATH}/:/usr/projects/ \
        -w /usr/src \
        --entrypoint /bin/bash \
        nextail/${SERVICE_NAME}_dev

## start-dev-nocache : start the docker environment in background without cache on build
start-dev-nocache: create-env
	@cd ${MKFILE_PATH}/docker/dagster \
	&& ${DOCKER_COMPOSE} build --no-cache \
	&& ${DOCKER_COMPOSE} up -d 

## stop-dev          : stop the the docker environment in background
stop-dev:
	@cd ${MKFILE_PATH}/docker/dagster \
	&& ${DOCKER_COMPOSE} down

## dev-clean         : clean all the created containers
dev-clean:
	@cd ${MKFILE_PATH}/docker/dagster \
	&& ${DOCKER_COMPOSE} down --rmi local

## dev-clean-full    : clean all the created containers and their data
dev-clean-full: 
	@cd ${MKFILE_PATH}/docker/dagster \
	&& ${DOCKER_COMPOSE} down --rmi local -v

## clean             : remove all build, test, coverage and Python artifacts
clean: clean-packages clean-pyc clean-test

## clean-packages    : remove build packages
clean-packages: 
	@bash scripts/clean-packages.sh

## clean-pyc         : remove python pyc files
clean-pyc: 
	@bash scripts/clean-pyc.sh

## clean-test        : remove test and coverage artifacts
clean-test:
	@bash scripts/clean-test.sh

## pdm-lock          : lock generator
pdm-lock:
	${DOCKER_COMPOSE} -f ${MKFILE_PATH}/docker/dev/docker-compose-pdm.yml build \
		--no-cache \
		--build-arg GITHUB_PIP_TOKEN=${GITHUB_PIP_TOKEN}&& \
	${DOCKER_COMPOSE} -f ${MKFILE_PATH}/docker/dev/docker-compose-pdm.yml run \
		--rm --no-deps lock-generator pdm lock -v