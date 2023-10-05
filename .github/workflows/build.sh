#!/bin/bash

# A script for building EPICS container images.
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

# a mapping between genenric IOC repo roots and the related container registry
export EC_REGISTRY_MAPPING='github.com=ghcr.io
gitlab.diamond.ac.uk=gcr.io/diamond-privreg/controls/ioc'

THIS=$(dirname ${0})

set -xe

pip install --upgrade -r ${THIS}/../../requirements.txt

# add extra cross compilation platforms below if needed  e.g.
#   ec dev build --buildx --arch rtems ... for RTEMS cross compile

# build runtime and developer images
ec dev build --buildx --tag ${TAG} --platform ${PLATFORM} --cache-to ${CACHE} \
--cache-from ${CACHE} ${PUSH}

# extract the ioc schema from the runtime image
ec dev launch-local --execute \
'ibek ioc generate-schema /epics/links/ibek/*.ibek.support.yaml' \
> ibek.ioc.schema.json

# run acceptance tests
${THIS}/../../tests/run-tests.sh

