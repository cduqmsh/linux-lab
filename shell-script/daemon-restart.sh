#!/bin/bash

. /home/user/.bash_profile

# restart image resizing daemon every day
ECHO_FILE="/home/user/restart_image_resizing_daemon.log"
touch $ECHO_FILE

echo "[`date`] kill -9 `ps -ef | grep -v grep | grep user | grep resize | grep java | awk '{print $2}'`" >> $ECHO_FILE

kill -9 `ps -ef | grep -v grep | grep user | grep resize | grep java | awk '{print $2}'`
