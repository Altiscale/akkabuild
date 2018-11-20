#!/usr/bin/env bash

PACKAGE_NAME=${PACKAGE_NAME:-"akka"}
PACKAGE_BRANCH=${PACKAGE_BRANCH:-"alti-v2.3.16_2.11"}
BUILD_BRANCH=${BUILD_BRANCH:-"alti-v2.3.16_2.11"}
DOCKER_BASE_IMAGE_NAME=buildenv-java8
BUILD_USER=jenkins-slave

# 1. build docker (compile environment)
docker build \
  -t ${DOCKER_BASE_IMAGE_NAME} \
  -f Dockerfile \
  .
retval=$?

if [[ ${retval} != 0 ]]; then
  echo "ERROR: Docker failed to build compile environment"
  exit ${retval}
fi

# 2. build docker (build package rpm)
rev=$(date "+%Y%m%d%H%M")
#DOCKER_RPMBUILD_IMAGE_NAME="${PACKAGE_NAME}build:${rev}"
DOCKER_RPMBUILD_IMAGE_NAME="${PACKAGE_NAME}build:latest"
echo "DOCKER_RPMBUILD_IMAGE_NAME: ${DOCKER_RPMBUILD_IMAGE_NAME}"

docker build \
  -t "${DOCKER_RPMBUILD_IMAGE_NAME}" \
  -f Dockerfile.build \
  .
retval=$?

if [[ ${retval} != 0 ]]; then
  echo "ERROR: Docker failed to build package environment"
  exit ${retval}
fi

export JENKINS_DIR="/home/$BUILD_USER"
export PACKAGE_BUILD_NAME="${PACKAGE_NAME}build"
export DOCKER_BUILD_DIR="${JENKINS_DIR}/build"

docker run \
  --rm \
  -v ${HOME}/.m2:/home/$BUILD_USER/.m2 \
  -v ${HOME}/.m2/repository:/home/$BUILD_USER/.m2/repository \
  -v ${PWD}:${DOCKER_BUILD_DIR} \
  -u $BUILD_USER \
  -w ${JENKINS_DIR} \
  --env=BUILD_BRANCH=${BUILD_BRANCH} \
  --env=PACKAGE_BRANCH=${PACKAGE_BRANCH} \
  --env=WORKSPACE=${DOCKER_BUILD_DIR} \
  --env=MAVEN_OPTS="${MAVEN_OPTS}" \
  ${DOCKER_RPMBUILD_IMAGE_NAME}
