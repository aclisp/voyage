unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
source /run/flannel/subnet.env

# Setup IP masquerade rule for traffic destined outside of overlay network
#sudo iptables -t nat -D POSTROUTING -o ${FLANNEL_IFACE} -j MASQUERADE \! -d ${FLANNEL_NETWORK}
#sudo iptables -t nat -A POSTROUTING -o ${FLANNEL_IFACE} -j MASQUERADE \! -d ${FLANNEL_NETWORK}

FLANNEL_SUBNET_IP=$(echo $FLANNEL_SUBNET | sed 's/\/.*//')

until kubectl cluster-info; do
	echo "Waiting for cluster up..."
	sleep 1
done
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


