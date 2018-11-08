#
# Copyright 2017-2018 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Build and deploy file for the ffdl-job-monitor
#

DOCKER_IMG_NAME = jobmonitor

#####################################################
# Dynamically get the commons makefile for shared
# variables and targets.
#####################################################
CM_REPO ?= raw.githubusercontent.com/ffdl-commons
CM_VERSION ?= master
CM_MK_LOC ?= .
CM_MK_NM ?= "ffdl-commons.mk"

# If the .mk file is changed on commons, and the file already exists here, it seems to update, but might take a while.
# Delete the file and try again to make sure, if you are having trouble.
CM_MK=$(shell wget -N https://${CM_REPO}/${CM_VERSION}/${CM_MK_NM} -P ${CM_MK_LOC} > /dev/null 2>&1 && echo "${CM_MK_NM}")

include $(CM_MK)

## show variable used in commons .mk include mechanism
show_cm_vars:
	@echo CM_REPO=$(CM_REPO)
	@echo CM_VERSION=$(CM_VERSION)
	@echo CM_MK_LOC=$(CM_MK_LOC)
	@echo CM_MK_NM=$(CM_MK_NM)

#####################################################

protoc: protoc-trainer protoc-lcm

vet:
	go vet $(shell glide nv)

lint:               ## Run the code linter
	go list ./... | grep -v /vendor/ | grep -v /grpc_trainer_v2 | xargs -L1 golint -set_exit_status

glide:               ## Run full glide rebuild
	glide cache-clear; \
	rm -rf vendor; \
	glide install

build-x86-64-jobmonitor:
	(CGO_ENABLED=0 GOOS=linux go build -ldflags "-s" -a -installsuffix cgo -o bin/main)

build-x86-64: build-x86-64-jobmonitor

docker-build: build-x86-64
	cd vendor/github.com/AISphere/ffdl-commons/grpc-health-checker && make build-x86-64
	(docker build --label git-commit=$(shell git rev-list -1 HEAD) -t "$(DOCKER_BX_NS)/$(DOCKER_IMG_NAME):$(DLAAS_IMAGE_TAG)" .)

.PHONY: all clean doctor usage showvars test-unit
