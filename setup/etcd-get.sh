source ./env.sh
etcdctl --peers=$MASTER_IP:4001 get $1 | python -m json.tool
