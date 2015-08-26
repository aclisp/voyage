unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

source ./env.sh
kube-apiserver --etcd-servers=http://$MASTER_IP:4001 --service-cluster-ip-range=10.10.1.0/24 --bind-address=$MASTER_IP --insecure-bind-address=0.0.0.0
