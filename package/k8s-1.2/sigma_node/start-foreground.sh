#!/bin/bash

KUBELET_OPTIONS=$(cat conf/kubelet-options.conf | tr '\n' ' ')
exec bin/hyperkube kubelet $KUBELET_OPTIONS
