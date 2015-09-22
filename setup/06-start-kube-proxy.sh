unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

kube-proxy --kubeconfig=/var/lib/sigma/kubeconfig --hostname-override=THIS_NODE --bind-address=THIS_NODE
