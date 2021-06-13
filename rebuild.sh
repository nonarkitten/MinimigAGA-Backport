#!/usr/bin/env bash

PROJ_DIR=./project_1

VIV_PATH=$(which vivado)
if [ -x "$VIV_PATH" ] ; then
    echo "Vivado is found at: ${VIV_PATH}"
else
    echo "##############################################################"
    echo "Vivado not at path."
    echo "please find settings64.sh in the vivado install and source it."
    echo "##############################################################"
    exit 1
fi

if [[ -d ${PROJ_DIR} ]]; then
    echo "${PROJ_DIR} already exists, exiting now."
    exit 1
fi

vivado -mode batch -source rebuild.tcl

echo "############################################################"
echo "Project rebuild done, the project can now be opened in Vivado."
echo "Path: $(realpath ${PROJ_DIR})"
echo "############################################################"
