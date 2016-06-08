bin/etcdctl set /coreos.com/network/config "$(<flannel-global.json)"
bin/etcdctl get /coreos.com/network/config
