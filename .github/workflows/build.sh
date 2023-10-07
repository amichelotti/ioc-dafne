#!/bin/bash

# A generic build script for epics-containers ioc repositories
#
# Note that this is implemented in bash to make it portable between
# CI frameworks. This approach uses the minimum of GitHub Actions.
# Also works locally for testing outside of CI
#
# INPUTS:
#   PUSH: if true, push the container image to the registry
#   TAG: the tag to use for the container image
#   PLATFORM: the platform to build for (linux/amd64 or linux/arm64)
#   CACHE: the directory to use for caching

TAG="--tag ${TAG:-latest}"
PLATFORM="--platform ${PLATFORM:-linux/amd64}"
CACHE="${CACHE:-/tmp/ec-cache}"
THIS=$(dirname ${0})
mkdir -p ${CACHE}
set -xe

# pip install --upgrade -r ${THIS}/../../requirements.txt
# TODO using developer branch for now
pip install git+https://github.com/epics-containers/epics-containers-cli.git@dev

# add extra cross compilation platforms below if needed  e.g.
#   ec dev build  --arch rtems ... for RTEMS cross compile

# build runtime and developer images
if [[ -n ${CACHE} ]] ; then CARGS="--cache-to ${CACHE} --cache-from ${CACHE}"; fi
if [[ "${PUSH}" == 'true' ]] ; then PUSH='--push' ; else PUSH='' ; fi

ec --log-level debug dev build ${TAG} ${PLATFORM} ${PUSH} ${CARGS}

# extract the ioc schema from the runtime image
ec dev launch-local --execute \
'ibek ioc generate-schema /epics/links/ibek/*.ibek.support.yaml' \
> ibek.ioc.schema.json

# run acceptance tests
shopt -s nullglob # expand to nothing if no tests are found
for t in "${THIS}/../../tests/*.sh"; do ${t}; done

