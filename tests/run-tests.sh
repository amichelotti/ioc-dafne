## command line options ########################################################
rebuild=false

while getopts "hr" arg; do
    case $arg in
    r)
        rebuild=true
        ;;
    *)
        echo "
usage: run-tests [options]

Runs a suite of tests for this module.

Options:

    -h              show this help
    -r              force rebuild of the container (default: false)
"
        exit 0
        ;;
    esac
done

################################################################################

THIS_DIR=$(realpath $(dirname $0))
ROOT=$(realpath ${THIS_DIR}/..)

set -ex

check_ioc() {
    export EPICS_CA_SERVER_PORT=7064
    base_args='
        --net podman
        -e EPICS_CA_SERVER_PORT
        ghcr.io/epics-containers/epics-base-linux-runtime:23.3.1
    '
    podman run ${base_args} caput ${1}:A 1.4
    podman run ${base_args} caput ${1}:B 1.5
    podman run ${base_args} caput ${1}:SUM.PROC 0
    podman run ${base_args} caget ${1}:SUM > /tmp/sum.txt
    if ! grep -q '2.9' /tmp/sum.txt ; then
        echo "ERROR: IOC unexpected result from ${1}:SUM"
        exit 1
    fi
}

# NOTE: all commands are written out in full to allow cut and paste to the
# command line for debugging from the root folder of this repo

cd ${ROOT}

# build the ioc-template container for linux ###################################
if ! podman image exists ioc-template-test-image || [[ ${rebuild} == "true" ]] ; then
    podman build -t ioc-template-test-image --build-arg TARGET_ARCHITECTURE=linux .
fi

# Test the default example IOC #################################################
podman rm -ft0 ioc-template-test-container
podman run --net podman --name ioc-template-test-container -dit ioc-template-test-image
check_ioc "EXAMPLE"

# Test an ibek IOC #############################################################
# podman rm -ft0 ioc-template-test-container
# podman run --net podman --name ioc-template-test-container -v $(pwd)/tests/example-ibek-config:/repos/epics/ioc/config -dit ioc-template-test-image
# check_ioc "EXAMPLE2"


