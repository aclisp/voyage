unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

source /run/flannel/subnet.env
FLANNEL_SUBNET_IP=$(echo $FLANNEL_SUBNET | sed 's/\/.*//')
kube-proxy --kubeconfig=/var/lib/sigma/kubeconfig --hostname-override=$FLANNEL_SUBNET_IP
