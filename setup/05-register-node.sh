unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

source /run/flannel/subnet.env
FLANNEL_SUBNET_IP=$(echo $FLANNEL_SUBNET | sed 's/\/.*//')

kubectl create -f - <<NODE_JSON
{
  "kind": "Node",
  "apiVersion": "v1",
  "metadata": {
    "name": "$FLANNEL_SUBNET_IP"
  },
  "spec": {
    "podCIDR": "$FLANNEL_SUBNET"
  }
}
NODE_JSON
