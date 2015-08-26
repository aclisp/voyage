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


