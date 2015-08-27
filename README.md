# voyage

A project utilizing docker and kubernetes.

# setup

	fab --list

	fab print_hosts

	fab -R master,slaves check_os

	fab -R master,slaves install_docker_prerequisites

	*** REBOOT ALL NODES ***

	fab -R master,slaves install_docker

# sigma install

	fab -R master,slaves install_binary

# sigma start

	fab -R master start_master
	fab -R slaves start_slave

# sigma stop
	
	fab -R slaves stop_slave
	fab -R master stop_master

# sigma status

	fab -R master status_master
	fab -R slaves status_slave

# check

	$ kubectl get no
	NAME           LABELS    STATUS    AGE
	172.16.109.1   <none>    Ready     30m
	172.16.20.1    <none>    Ready     30m
	172.16.82.1    <none>    Ready     1h
	172.16.95.1    <none>    Ready     30m
 
	$ kubectl get cs
	NAME                 STATUS    MESSAGE              ERROR
	controller-manager   Healthy   ok                   nil
	scheduler            Healthy   ok                   nil
	etcd-0               Healthy   {"health": "true"}   nil

# add rc

	$ kubectl create -f rc.nginx.yaml 
	replicationcontroller "nginx-controller" created

	$ kubectl get rc
	CONTROLLER         CONTAINER(S)   IMAGE(S)   SELECTOR    REPLICAS   AGE
	nginx-controller   nginx          nginx      app=nginx   4          5m

	$ kubectl get po -o wide
	NAME                     READY     STATUS                                  RESTARTS   AGE       NODE
	nginx-controller-ivrfp   0/1       Image: nginx is not ready on the node   0          6m        172.16.109.1
	nginx-controller-lvzza   0/1       Image: nginx is not ready on the node   0          6m        172.16.95.1
	nginx-controller-meaxg   0/1       Image: nginx is not ready on the node   0          6m        172.16.82.1
	nginx-controller-tb9c5   0/1       Image: nginx is not ready on the node   0          6m        172.16.20.1

	<After a while...>
	$ kubectl get po -o wide
	NAME                     READY     STATUS    RESTARTS   AGE       NODE
	nginx-controller-ivrfp   1/1       Running   0          2h        172.16.109.1
	nginx-controller-lvzza   1/1       Running   0          2h        172.16.95.1
	nginx-controller-meaxg   1/1       Running   0          2h        172.16.82.1
	nginx-controller-tb9c5   1/1       Running   0          2h        172.16.20.1
