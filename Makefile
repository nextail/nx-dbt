.PHONY = help dev-deps update test create-env start-dev shell start-dev-nocache stop-dev dev-clean dev-clean-full clean clean-packages clean-pyc clean-test pdm-lock
MAKEFLAGS += --warn-undefined-variables

REPO_NAME := $(shell basename `git config --get remote.origin.url` .git)
SERVICE_NAME := $(shell echo $(REPO_NAME) | tr '-' '_')

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

## update            : This script updates all references.
update: dev-deps
	@bash scripts/update-template.sh

## test              : pytest
test: dev-deps
	@echo \
	&& DOCKER_BUILDKIT=1 \
	${DOCKER} build --no-cache --target test -t nextail/${REPO_NAME}_test \
		--build-arg GITHUB_PIP_TOKEN=${GITHUB_PIP_TOKEN} \
		--build-arg SERVICE_NAME=${SERVICE_NAME} \
		--build-arg REPO_NAME=${REPO_NAME} \
		-f ${MKFILE_PATH}/docker/Dockerfile ${MKFILE_PATH} \
	&& echo \
	&& ${DOCKER} run --rm -it nextail/${REPO_NAME}_test \
	pytest -c /usr/python/pyproject.toml

## create-env        : create .env file
create-env: 

	@echo "SERVICE_NAME=${SERVICE_NAME}" > ${MKFILE_PATH}/docker/dagster/.env
	@echo "REPO_NAME=${REPO_NAME}" >> ${MKFILE_PATH}/docker/dagster/.env
	
## start-dev         : start the docker environment in background
start-dev: create-env
	
	@cd ${MKFILE_PATH}/docker/dagster \
	&& DOCKER_BUILDKIT=1 \
	${DOCKER_COMPOSE} up --build -d

## shell             : start the docker environment in background with shell
shell: start-dev
	@echo \
	&& DOCKER_BUILDKIT=1 \
	${DOCKER} build --target dev -t nextail/${REPO_NAME}_dev \
		--build-arg UNAME=local-dev \
		--build-arg USER_ID=${UID} \
		--build-arg GROUP_ID=${GID} \
		--build-arg GITHUB_PIP_TOKEN=${GITHUB_PIP_TOKEN} \
		--build-arg SERVICE_NAME=${SERVICE_NAME} \
		--build-arg REPO_NAME=${REPO_NAME} \
		-f ${MKFILE_PATH}/docker/Dockerfile ${MKFILE_PATH} \
	&& echo \
	&& echo -e "${BLUE}Dockerized ${NOFORMAT} shell ready to interact with the project." \
	&& echo -e "Execute ${CYAN}'exit'${NOFORMAT} to close and remove the container.\n" \
	&& ${DOCKER} run --rm -it --network=nxnet \
        --hostname dagster-shell \
		--user local-dev:local-dev \
        -v ${MKFILE_PATH}/:/opt/${REPO_NAME}/ \
        -w /opt/${REPO_NAME}/ \
        --entrypoint /bin/bash \
        nextail/${REPO_NAME}_dev

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
	@bash scripts/clean-pkg.sh

## clean-pyc         : remove python pyc files
clean-pyc: 
	@bash scripts/clean-pyc.sh

## clean-test        : remove test and coverage artifacts
clean-test:
	@bash scripts/clean-test.sh

## pdm-lock          : lock generator
pdm-lock:
	@echo \
	&& DOCKER_BUILDKIT=1 \
	${DOCKER} build --target dev -t nextail/${REPO_NAME}_dev \
		--build-arg UNAME=local-dev \
		--build-arg USER_ID=${UID} \
		--build-arg GROUP_ID=${GID} \
		--build-arg GITHUB_PIP_TOKEN=${GITHUB_PIP_TOKEN} \
		--build-arg SERVICE_NAME=${SERVICE_NAME} \
		--build-arg REPO_NAME=${REPO_NAME} \
		-f ${MKFILE_PATH}/docker/Dockerfile ${MKFILE_PATH} \
	&& echo \
	&& ${DOCKER} run --rm -it --network=nxnet \
        --hostname dagster-lock \
		--user local-dev:local-dev \
        -v ${MKFILE_PATH}/:/opt/${REPO_NAME}/ \
        -w /opt/${REPO_NAME}/ \
        nextail/${REPO_NAME}_dev \
		pdm lock -v
