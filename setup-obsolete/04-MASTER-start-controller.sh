unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

kube-controller-manager --kubeconfig=/var/lib/sigma/kubeconfig
