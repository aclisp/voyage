source ./env.sh
etcdctl --peers=$MASTER_IP:4001 ls --recursive -p
