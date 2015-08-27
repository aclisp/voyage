from fabric.api import *

port = 32200
hosts = [
	'10.21.196.101', 
	'10.21.196.123',
	'10.21.198.37',
	'10.21.198.38',
]

env.colorize_errors = True
_hosts = [x + ':' + str(port) for x in hosts]
env.roledefs['master'] = _hosts[0:1]
env.roledefs['slaves'] = _hosts[1:]


@task
def print_hosts():
	for x in _hosts:
		print x

@task
def check_os():
	run('lsb_release -a | grep -w precise')

@task
def install_docker_prerequisites():
	check_os()
	sudo('apt-get update')
	sudo('apt-get upgrade')
	sudo('apt-get -y install linux-image-generic-lts-trusty')
	print " *** NEED TO REBOOT MANUALLY *** "

@task
def install_docker():
	kernel_version = run("uname -r | sed 's/-.*//'")
	if kernel_version != '3.13.0':
		print " *** KERNEL VERSION ERROR *** "
		return
	sudo('apt-get -y install curl')
	sudo('apt-get -y install sysv-rc-conf')
	sudo('apt-get -y install bridge-utils')
	run('curl -sSL https://get.docker.com/ | sh')
	# Disable service auto-start!
	sudo('service docker stop; true')
	sudo('sysv-rc-conf docker off')
	sudo('echo manual > /etc/init/docker.override')
	sudo('ip link set dev docker0 down; true')
	sudo('brctl delbr docker0; true')
	sudo('iptables -t nat -n -L')
	sudo('iptables -t nat -F')

@task
def install_binary():
	with lcd("$HOME"):
		packages = local('ls -1r sigma-package-*.tar.gz', capture=True)
		#print " SIGMA PACKAGES ARE "
		#print packages
		package = packages.split()[0] # Get the latest version!
		if env.host:
			local('scp {pkg} {host}:/tmp'.format(pkg=package, host=env.host))
	sudo("tar zxvf /tmp/{pkg} -C /usr/local/bin/".format(pkg=package))
	# Verify binary in PATH
	sudo("which "
		"docker "
		"flanneld "
		"kubelet "
		"kubectl "
		"kube-apiserver "
		"kube-controller-manager "
		"kube-scheduler")
	# Install SIGMA scripts
	run("sudo mkdir -p "
		"/opt/sigma/bin "
		"/var/log/sigma "
		"/var/lib/sigma "
		"/run/sigma")
	run("mkdir -p ~/sigma/bin")
	local('scp *.sh {host}:~/sigma/bin'.format(host=env.host))
	run('sudo cp ~/sigma/bin/* /opt/sigma/bin')
	# Setup kubectl
	run('/opt/sigma/bin/00-setup-kubectl.sh')
	run('sudo cp ~/.kube/config /var/lib/sigma/kubeconfig')

def as_daemon(script, pidfile, logfile):
	# http://stackoverflow.com/questions/8251933/how-can-i-log-the-stdout-of-a-process-started-by-start-stop-daemon
	return ('start-stop-daemon --start --oknodo '
			'--make-pidfile --pidfile {pidfile} '
			'--background --startas /bin/bash '
			'-- -c "exec {script} >{logfile} 2>&1"'.format(
				script=script, 
				pidfile=pidfile,
				logfile=logfile))

@task
def start_master():
	sudo(as_daemon('/opt/sigma/bin/00-MASTER-start-etcd.sh',      '/run/sigma/etcd.pid',       '/var/log/sigma/etcd.log'))
	sudo(as_daemon('/opt/sigma/bin/01-start-flanneld.sh',         '/run/sigma/flanneld.pid',   '/var/log/sigma/flanneld.log'))
	sudo(          '/opt/sigma/bin/02-create-cbr0.sh')
	sudo(as_daemon('/opt/sigma/bin/03-start-docker-daemon.sh',    '/run/sigma/docker.pid',     '/var/log/sigma/docker.log'))
	sudo(as_daemon('/opt/sigma/bin/04-start-kubelet.sh',          '/run/sigma/kubelet.pid',    '/var/log/sigma/kubelet.log'))
	sudo(as_daemon('/opt/sigma/bin/04-MASTER-start-apiserver.sh', '/run/sigma/apiserver.pid',  '/var/log/sigma/apiserver.log'))
	sudo(as_daemon('/opt/sigma/bin/04-MASTER-start-controller.sh','/run/sigma/controller.pid', '/var/log/sigma/controller.log'))
	sudo(as_daemon('/opt/sigma/bin/04-MASTER-start-scheduler.sh', '/run/sigma/scheduler.pid',  '/var/log/sigma/scheduler.log'))
	run(           '/opt/sigma/bin/05-register-node.sh')

