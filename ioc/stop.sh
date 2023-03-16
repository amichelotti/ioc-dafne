#!/bin/bash
TOP=$(realpath $(dirname $0))
cd ${TOP}
CONFIG_DIR=${TOP}/config

override=${CONFIG_DIR}/stop.sh

if [[ -f ${override} ]]; then
    exec ${override}
elif [[ ${RTEMS_VME_AUTO_REBOOT} == 'true' ]] ; then
    killall telnet
    sleep 5
fi


