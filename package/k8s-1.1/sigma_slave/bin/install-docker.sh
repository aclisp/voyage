#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -e /etc/centos-release ]]; then
    bash $THIS_DIR/install-docker-centos.sh
elif [[ -e /etc/lsb-release ]]; then
    bash $THIS_DIR/install-docker-ubuntu.sh
else
    >&2 echo "OS should be centos or ubuntu to run docker!"
    exit 1
fi
