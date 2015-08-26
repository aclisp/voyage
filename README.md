# voyage

A project utilizing docker and kubernetes.

# setup

	fab --list

	fab print_hosts

	fab -R master,slaves check_os

	fab -R master,slaves install_docker_prerequisites

	*** REBOOT ALL NODES ***

	fab -R master,slaves install_docker


