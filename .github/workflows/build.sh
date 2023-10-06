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

if [[ ${PUSH} == 'true' ]] ; then PUSH='--push' ; else PUSH='' ; fi
TAG=${TAG:-latest}
PLATFORM=${PLATFORM:-linux/amd64}
CACHE=${CACHE:-/tmp/ec-cache}
THIS=$(dirname ${0})
set -xe

if ! ec --version 2> /dev/null ; then
    # pip install --upgrade -r ${THIS}/../../requirements.txt
    # TODO TODO - using latest dev of ec for the moment
    pip install git+https://github.com/epics-containers/epics-containers-cli@dev
fi

# add extra cross compilation platforms below if needed  e.g.
#   ec dev build --buildx --arch rtems ... for RTEMS cross compile

# build runtime and developer images
ec --log-level debug dev build --buildx --tag ${TAG} --platform ${PLATFORM} \
--cache-to ${CACHE} --cache-from ${CACHE} ${PUSH}

# extract the ioc schema from the runtime image
ec dev launch-local --tag ${TAG} --execute \
'ibek ioc generate-schema /epics/links/ibek/*.ibek.support.yaml' \
> ibek.ioc.schema.json

# run acceptance tests
shopt -s nullglob # expand to nothing if no tests are found
for t in "${THIS}/../../tests/*.sh"; do bash ${t}; done

