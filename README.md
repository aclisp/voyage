# Voyage

A project utilizing docker and kubernetes.

Also see my blog:

* [Install k8s from scratch](http://aclisp.github.io/blog/2015/08/20/kubernetes-scratch.html)
* [Start k8s cluster](http://aclisp.github.io/blog/2015/08/25/kubernetes-startup.html)

## Branch information

* `master` - Networking with flannel
* `purehost` - Not containerize the container’s networking

**Currenly I am working on branch `purehost`.**

# Setup

	fab --list

	fab print_hosts

	fab -R master,slaves check_os

	fab -R master,slaves install_docker_prerequisites

	*** REBOOT ALL NODES ***

	fab -R master,slaves install_docker

# Install or update binaries and scripts

	fab -R master,slaves install_binary

# Start the cluster

	fab -R master start_master
	fab -R slaves start_slave

# Stop the cluster

	fab -R slaves stop_slave
	fab -R master stop_master

# Check status

	fab -R master status_master
	fab -R slaves status_slave

# Verify

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

# Add a replication controller

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
