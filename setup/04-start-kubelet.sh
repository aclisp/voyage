unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
mkdir -p /etc/kubernetes/manifests
kubelet --config=/etc/kubernetes/manifests --configure-cbr0=false --register-node=false --api-servers=$MASTER_IP:8080 --address=THIS_NODE --hostname-override=THIS_NODE --host-network-sources="file,api"
