#!/bin/bash

# `config.sh` 每次启动都被调用。用于把 `master-info` 里的配置转换成 k8s 有效配置。
#

source $INSTALL_PATH/conf/master-info.conf
# Specify how to authenticate to API server (the master location is set by the api-servers flag)
cat > /tmp/kubeconfig << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: ${API_SERVER}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: default
    user: myself
  name: default-context
current-context: default-context
preferences:
  colors: true
users:
- name: myself
  user:
    password: ${PASSWORD}
    username: ${USER}
EOF
mkdir -p /var/lib/kubelet
\mv -f /tmp/kubeconfig /var/lib/kubelet/kubeconfig

# Specify how to connect to API server (i.e. the master location)
\cp -f $INSTALL_PATH/conf/kubelet.tmpl.conf $INSTALL_PATH/conf/kubelet.conf
sed -i "s#@@API_SERVER@@#${API_SERVER}#g" $INSTALL_PATH/conf/kubelet.conf
sed -i "s#@@INSTALL_PATH@@#${INSTALL_PATH}#g" $INSTALL_PATH/conf/kubelet.conf
sed -i "s#@@ETH0_IP@@#${ETH0_IP}#g" $INSTALL_PATH/conf/kubelet.conf
