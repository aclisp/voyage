Sigma 包发布指南
-----

# 前提

物理主机上架时

* 装好 docker
* master 机导入 [docker image](https://hub.docker.com/u/sigmas/)
    - etcd
    - kube-apiserver
    - kube-controller-manager
    - kube-scheduler

# 程序包

## 文件

按目录结构上传

## 脚本

`脚本相关` -> `启动方式` 修改部分：

	#---------------#
	# 启动进程       #
	#---------------#

	cd $INSTALL_PATH/bin || exit 1

	# Add by 黄灏
	find ../conf/manifests -name '*.bak' -exec rm -f {} \;
	find ../conf/manifests -name '*.old' -exec rm -f {} \;
	APP_OPTION=$(cat ../conf/$APP_NAME.conf | tr '\n' ' ')

	for ((i=1;i<=$y;i++)); do
		echo "start #$i"
		nohup ./$APP_NAME $APP_OPTION >>$log 2>&1 &
		sleep 2
	done

**注意：**

- `$APP_NAME.conf` 文件里不要有多余空行
- `$APP_NAME.conf` 文件里不要有引号`"`和`'`

# 防火墙

每个主机默认阻止所有公网 IP 的接入：

	sudo iptables -A INPUT -d SERVER_IP -j DROP -m comment --comment "sigma"

每个 kubelet 在公网监听三个端口，全部阻止没有问题。

* 10250 调试端口
* 10255 只读端口，给 heapster 用
* 4194  cadvisor 端口

master 主机**按需**开放 kube-apiserver

	sudo iptables -I INPUT -s CLIENT_IP -d SERVER_IP -p tcp --dport 6443 -j ACCEPT -m comment --comment "sigma"

# 清 docker logs

创建文件 `/etc/logrotate.d/docker-container` 内容如下

    /var/lib/docker/containers/*/*.log {
        rotate 5
        nocompress
        nodateext
        missingok
        copytruncate
        size 10M
        notifempty
    }

