SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help
.PHONY: clean requirements plugins build logs e2e

jenkins_version="jenkins-1.6"

help:
	@echo ''
	@echo 'Makefile for '
	@echo '     make help            show this information'
	@echo '     make clean           shutdown running container and delete image and clean workspace'
	@echo '     make clean.container shutdown running container and delete image'
	@echo '     make clean.ws        delete all groovy/gradle artifacts in the workspace'
	@echo '     make build           build a dockerfile for testing the jenkins configuration'
	@echo '     make run             run the dockerfile in the background'
	@echo '     make logs            tail the logs for the Jenkins container'
	@echo '     make shell           shell into the runnning Jenkkins container for debugging'
	@echo '     make healthcheck     run healthcheck script to test if Jenkins has successfully booted'
	@echo '     make quality         run codenarc on groovy source and tests'
	@echo '     make requirements    install requirements for acceptance tests'
	@echo '     make plugins         install specified Jenkins plugins and their dependencies'
	@echo '     make e2e             run python acceptance tests against a provisioned docker container'

clean: clean.container clean.ws

clean.container:
# run the following docker commands with '|| true' because they do not have a 'quiet' flag
	docker kill $(jenkins_version) || true
	docker rm $(jenkins_version) || true
	docker rmi $(jenkins_version) || true

clean.ws:
	./gradlew clean

build:
	docker build -t $(jenkins_version) --build-arg=CONFIG_PATH=$(CONFIG_PATH) .

run:
	docker run --name $(jenkins_version) -p 8080:8080 -d $(jenkins_version)

logs:
	docker logs -f $(jenkins_version)

shell:
	docker exec -it $(jenkins_version) /bin/bash

healthcheck:
	./healthcheck.sh

quality:
	./gradlew codenarcMain codenarcTest

requirements:
	./gradlew libs
	pip install -r test-requirements.txt

plugins:
	./gradlew -b plugins.gradle plugins

e2e:
	pytest
