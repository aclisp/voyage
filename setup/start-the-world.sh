fab -R master start_master
sleep 2

fab -R master start_master
sleep 2

if ! fab -R master status_master; then
	exit
fi

fab -R slaves start_slave
sleep 2

fab -R slaves start_slave
sleep 2

if ! fab -R slaves status_slave; then
	exit
fi
