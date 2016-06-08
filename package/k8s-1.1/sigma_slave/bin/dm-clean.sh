#!/bin/bash

DEVICE_LIST=$(lsblk | grep -oE "docker-.+-[a-z0-9]{64}" | sort | uniq)
DOCKER_LIST=$(docker ps -q)
DEVICE_LIST_SHORT=$(echo $DEVICE_LIST | tr ' ' '\n' | grep -oE "[a-z0-9]{64}" | cut -c-12)
GABAGE=$(echo $DOCKER_LIST $DEVICE_LIST_SHORT | tr ' ' '\n' | sort | uniq -u)

[[ -z $GABAGE ]] && echo "No gabage."
