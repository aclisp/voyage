unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
source /run/flannel/subnet.env
mkdir -p /etc/kubernetes/manifests
FLANNEL_SUBNET_IP=$(echo $FLANNEL_SUBNET | sed 's/\/.*//')
kubelet --config=/etc/kubernetes/manifests --configure-cbr0=false --register-node=false --api-servers=$MASTER_IP:8080 --address=0.0.0.0 --hostname-override=$FLANNEL_SUBNET_IP
