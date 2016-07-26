#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

cd $INSTALL_PATH/bin || exit 1

# Rotate docker logs
cat > /tmp/docker-container << EOF
/var/lib/docker/containers/*/*.log {
    rotate 5
    nocompress
    nodateext
    missingok
    copytruncate
    size 10M
    notifempty
}

/data/docker/containers/*/*.log {
    rotate 5
    nocompress
    nodateext
    missingok
    copytruncate
    size 10M
    notifempty
}
EOF
cp -f /tmp/docker-container /etc/logrotate.d/docker-container
