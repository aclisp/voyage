#!/bin/bash

KUBELET_OPTIONS=$(cat conf/kubelet-options.conf | tr '\n' ' ')
exec bin/kubelet $KUBELET_OPTIONS
