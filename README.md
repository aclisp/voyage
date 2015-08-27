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
