.PHONY = help dev-deps test start-dev start-dev-nocache stop-dev dev-clean dev-clean-full clean-build clean-pyc clean-test clean-persistence
MAKEFLAGS += --warn-undefined-variables

# Shell to use for running scripts
SHELL := $(shell which bash)

# Get docker path or an empty string
DOCKER := $(shell command -v docker)
# Get docker-compose path or an empty string
DOCKER_COMPOSE := $(shell command -v docker-compose)
# Get current path
MKFILE_PATH := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

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
	
## start-dev         : start the docker environment in background
start-dev: 
	@cd ${MKFILE_PATH}/docker/dagster && ${DOCKER_COMPOSE} up --build -d

## start-dev-nocache : start the docker environment in background without cache on build
start-dev-nocache: 
	@cd ${MKFILE_PATH}/docker/dagster && ${DOCKER_COMPOSE} build --no-cache && ${DOCKER_COMPOSE} up -d 

## stop-dev          : stop the the docker environment in background
stop-dev: 
	@cd ${MKFILE_PATH}/docker/dagster && ${DOCKER_COMPOSE} down

## dev-clean         : clean all the created containers
dev-clean:
	@cd ${MKFILE_PATH}/docker/dagster && ${DOCKER_COMPOSE} down --rmi local

## dev-clean-full    : clean all the created containers and their data
dev-clean-full: 
	@cd ${MKFILE_PATH}/docker/dagster &&${DOCKER_COMPOSE} down --rmi local -v

## clean             : remove all build, test, coverage and Python artifacts
clean: clean-build clean-pyc clean-test clean-persistence

## clean-build       : remove build artifacts
clean-build: 
	@rm -fr build/
	@rm -fr dist/
	@rm -fr .eggs/
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +

## clean-pyc         : remove Python file artifacts
clean-pyc: 
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +
## clean-test        : remove test and coverage artifacts
clean-test:
	@find . -name '.pytest_cache' -exec rm -fr {} +

## clean-persistence : remove local persistence
clean-persistence:
	@find . -name '.logs_queue' -exec rm -fr {} +
	@find . -name 'history' -exec rm -fr {} +
	@find . -name 'logs' -exec rm -fr {} +
	@find . -name 'storage' -exec rm -fr {} +