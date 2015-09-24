DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh
kubectl config set preferences.colors true
kubectl config set-credentials myself --username=admin --password=secret
kubectl config set-cluster kubernetes --server=http://$MASTER_IP:6443 --insecure-skip-tls-verify=true
kubectl config set-context default-context --cluster=kubernetes --user=myself
kubectl config use-context default-context
kubectl config set contexts.default-context.namespace default
kubectl config view

