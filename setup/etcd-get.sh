DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
etcdctl --peers=127.0.0.1:4001 get $1 | python -m json.tool
