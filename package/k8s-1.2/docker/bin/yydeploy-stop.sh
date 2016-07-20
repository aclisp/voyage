#!/bin/bash
set -x  # turn on trace
set +e  # turn off exit immediately

#----------------#
# 初始化日志文件 #
#----------------#

log=$INSTALL_PATH/admin/stop.log

true > $log

#---------------#
# 进程数量检查  #
#---------------#

pid=$(pidof $APP_NAME)

if [ -z "$pid" ] ; then
    echo "no running $APP_NAME found , already stopped"
    exit 0
fi

#---------------#
# 停止进程      #
#---------------#

# Stop running docker cleanly
bash $INSTALL_PATH/bin/_docker-stop.sh

for i in $pid ; do
     echo "kill $APP_NAME pid=$i [$(ps --no-headers -lf $i)]"
     kill $i
     [ $? -eq 0 ] && ( bash /data/pkg/public-scripts/func/common-cleanup.sh $i ) &
     sleep 5
done

#---------------#
# 二次确认       #
#---------------#

if [ -z "$(pidof $APP_NAME)" ] ; then
     echo "stop $APP_NAME ok, all $APP_NAME got killed"
     echo "output last 20 lines of $log"
     tail -n 20 $log
     exit 0
else
     echo "stop $APP_NAME failed, found $APP_NAME still running . see following"
     pidof $APP_NAME | xargs -r ps -lf
     echo "output last 20 lines of $log"
     tail -n 20 $log
     exit 1
fi
