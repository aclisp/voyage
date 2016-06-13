#!/bin/bash
set -x
set +H

# This file safely shutdown all the components of sigma slave.
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Disable package auto-restart
touch $THIS_DIR/../admin/.no-autostart

# Disable docker containers auto-restart (aka. stop kubelet)
$THIS_DIR/../admin/stop.sh

# Stop docker safely and cleanly
bash $THIS_DIR/_docker-stop.sh

