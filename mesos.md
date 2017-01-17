# 开发指南

源代码下载

    wget http://mirrors.hust.edu.cn/apache/mesos/1.1.0/mesos-1.1.0.tar.gz

安装支持 c++11 的 gcc

    http://ubuntuhandbook.org/index.php/2013/08/install-gcc-4-8-via-ppa-in-ubuntu-12-04-13-04/

官方文档

    http://mesos.apache.org/gettingstarted/


构建命令

    $ mkdir build
    $ cd build
    $ ../configure --prefix=$HOME/mesos/prefix --enable-dependency-tracking --enable-silent-rules --disable-maintainer-mode --enable-debug --disable-java --disable-python --disable-python-dependency-install --enable-install-module-dependencies CXX=/usr/bin/g++-4.8 CC=/usr/bin/gcc-4.8 CPP=/usr/bin/cpp-4.8 CXXCPP=/usr/bin/cpp-4.8
    $ make
    $ make check
    $ make install

# 安装指南

官方文档

    https://mesosphere.com/blog/2014/07/17/mesosphere-package-repositories/

安装命令

    $ sudo apt-get install mesos marathon

安装 Java 8 (Ubuntu) (Required by Marathon)

    $ sudo add-apt-repository ppa:webupd8team/java
    $ sudo apt-get update
    $ sudo apt-get install oracle-java8-installer
    $ sudo apt-get install oracle-java8-set-default

    https://github.com/mesosphere/marathon/issues/2357

配置方法

    https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04

如何上传 artifact

    https://github.com/mesosphere/marathon/issues/1305

    $ curl -v -XPOST http://119.147.176.214:8080/v2/artifacts --form file=@music_dbgate_m

# Master Nodes (CentOS 6)

安装 ZooKeeper (CentOS 6)

	https://open.mesosphere.com/advanced-course/installing-zookeeper/

    # rpm -Uvh http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm
    # yum -y install zookeeper zookeeper-server
    # EDIT! /etc/zookeeper/conf/zoo.cfg

    dataDir=/data1/zookeeper
    clientPortAddress=127.0.0.1

安装 Java 8 (CentOS 6) (Required by Marathon)

	https://gist.github.com/rjurney/7c855a0afa48777755d2

    # yum remove -y java-1.6.0-openjdk
    # UPLOAD! jdk-8u111-linux-x64.rpm libevent2-2.0.21-11.1.x86_64.rpm libevent2-devel-2.0.21-11.1.x86_64.rpm
    # rpm -Uvh jdk-8u111-linux-x64.rpm libevent2-2.0.21-11.1.x86_64.rpm libevent2-devel-2.0.21-11.1.x86_64.rpm
    # alternatives --display java 

安装 Mesos (CentOS 6)

    # rpm -Uvh http://repos.mesosphere.com/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm
    # yum -y install mesos marathon 
    # stop mesos-slave
    # echo "manual" > /etc/init/mesos-slave.override

设置 Zookeeper 集群

    # zookeeper-server-initialize --myid=1 (or 2, or 3)
    # chown -R zookeeper:zookeeper /data1/zookeeper
    # EDIT! /etc/zookeeper/conf/zoo.cfg

    server.1=61.160.36.73:2888:3888
    server.2=61.160.36.74:2888:3888
    server.3=61.160.36.75:2888:3888

    # /etc/init.d/zookeeper-server start

设置 Mesos Master (单点，禁用其它点自启)

    # cd /etc/mesos
    # echo "zk://61.160.36.73:2181,61.160.36.74:2181,61.160.36.75:2181/mesos" > zk
    # cd /etc/mesos-master
    # echo "1" > quorum
    # echo "40" > max_agent_ping_timeouts
    # echo "0%" > recovery_agent_removal_limit
    # mkdir -p /data1/mesos
    # echo "/data1/mesos" > work_dir
    # echo "61.160.36.73" > hostname
    # echo "61.160.36.73" > ip 
    # start mesos-master

设置 Marathon (单点，禁用其它点自启)

    # mkdir -p /etc/marathon/conf
    # cd /etc/marathon/conf
    # mkdir -p /data1/artifact_store
    # echo "file:///data1/artifact_store" > artifact_store
    # echo "task_killing" > enable_features
    # echo "61.160.36.73" > hostname
    # echo "admin:secretdbgate" > http_credentials
    # echo "8081" > http_port
    # echo "zk://61.160.36.73:2181,61.160.36.74:2181,61.160.36.75:2181/mesos" > master
    # echo "zk://61.160.36.73:2181,61.160.36.74:2181,61.160.36.75:2181/marathon" > zk
    # start marathon

# Slave Nodes (Ubuntu)

安装软件包

    # apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
    # DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    # CODENAME=$(lsb_release -cs)
    # echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
    # apt-get update
    # apt-get install mesos

关闭不需要的自启动项

    # stop zookeeper
    # echo "manual" > /etc/init/zookeeper.override
    # stop mesos-master
    # echo "manual" > /etc/init/mesos-master.override
    
写入配置项：工作目录 

    # echo "/data/mesos" > /etc/mesos-slave/work_dir

写入配置项：获取电信IP

    # echo $(grep ip_isp_list /home/dspeak/yyms/hostinfo.ini | sed 's/^ip_isp_list=//' | awk -F',' '{ for(i = 1; i <= NF; i++) { if ($i ~ /:CTL$/) print $i; } }' | sed 's/:CTL$//' | head -n 1) > /etc/mesos-slave/hostname
    # cp /etc/mesos-slave/hostname /etc/mesos-slave/ip

写入配置项：slave的属性

    # mkdir /etc/mesos-slave/attributes
    # echo $(grep idc_id /home/dspeak/yyms/hostinfo.ini | sed 's/^idc_id=//' | head -n 1) > /etc/mesos-slave/attributes/idc_id

写入配置项：master的IP:Port

    # echo "61.160.36.73:5050" > /etc/mesos/zk
    
启动服务 

    # start mesos-slave

# Marathon Setup

    # mkdir -p /etc/marathon/conf

    # https://github.com/mesosphere/marathon/issues/2153
    # echo "LIBPROCESS_IP=$(grep ip_isp_list /home/dspeak/yyms/hostinfo.ini | sed 's/^ip_isp_list=//' | awk -F',' '{ for(i = 1; i <= NF; i++) { if ($i ~ /:CTL$/) print $i; } }' | sed 's/:CTL$//' | head -n 1)" > /etc/default/marathon

    # mkdir /data1/artifact_store
    # echo "file:///data1/artifact_store" > /etc/marathon/conf/artifact_store
    # echo $(grep ip_isp_list /home/dspeak/yyms/hostinfo.ini | sed 's/^ip_isp_list=//' | awk -F',' '{ for(i = 1; i <= NF; i++) { if ($i ~ /:CTL$/) print $i; } }' | sed 's/:CTL$//' | head -n 1) > /etc/marathon/conf/hostname
    # echo "zk://localhost:2181/marathon" > /etc/marathon/conf/zk
    # echo "zk://localhost:2181/mesos" > /etc/marathon/conf/master
    # echo "8081" > /etc/marathon/conf/http_port
    # start marathon

