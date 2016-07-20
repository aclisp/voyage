#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

cd $INSTALL_PATH/bin || exit 1
./install-docker.sh
