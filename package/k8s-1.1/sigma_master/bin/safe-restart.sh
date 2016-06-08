#!/bin/bash
set -x
set +H

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Shutdown safely and cleanly
bash $THIS_DIR/safe-shutdown.sh

# Should get a clean state here, now starting...
service docker start
service monit start
rm -f $THIS_DIR/../admin/.no-autostart
$THIS_DIR/../admin/start.sh
