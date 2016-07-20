#!/bin/bash

SIGNODE_OPTIONS=$(cat conf/signode-options.conf | tr '\n' ' ')
exec bin/signode $SIGNODE_OPTIONS
