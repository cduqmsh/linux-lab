- **unison + inotifywait (디렉토리 복제 오픈소스 + 실시간 복제 오픈소스)**

```
**Ubuntu 22.04 환경 

apt install -y unison
apt install -y inotify-tools**

**아래 스크립트 작성(디렉토리 계정 권한이 users2라 users2로 작성)
/home/users2/scripts/inotifywait.sh
#!/bin/bash

WATCH_DIR="/unison/test"
REMOTE="ssh://users2@1.1.1.1//unison/test"
SSH_PORT=2222

LOG_FILE="/home/users2/scripts/inotifywait.log"

echo "$(date) Start watching $WATCH_DIR" >> $LOG_FILE

inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" | while read path action file; do
    echo "$(date) Change detected: $path $action $file" >> $LOG_FILE
    /usr/bin/unison "$WATCH_DIR" "$REMOTE" -batch -auto -sshargs "-p $SSH_PORT" >> $LOG_FILE 2>&1
done**

WATCH_DIR은 동기화 할 디렉터리
사전에 users2 계정으로 ssh 로그인이 비밀번호 없이 접속 확인
쉘을 항상 기동 시켜야 동작을 하지만 서비스로 등록하여 쉽게 관리

**서비스 등록 (등록은 root로 진행)
vi /etc/systemd/system/inotifywait.service
[Unit]
Description=Unison Directory Sync Watcher using inotifywait
After=network.target

[Service]
Type=simple
ExecStart=/home/users2/scripts/inotifywait.sh
Restart=always
RestartSec=5
User=users2

[Install]
WantedBy=multi-user.target**

systemctl daemon-reload
systemctl start inotifywait.service 

동기화 확인 / 서버 1에서 파일 생성,삭제,수정 시 서버 2에서도 파일 생성,삭제,수정
```

---

- **CentOS 6에서 실제 적용했던 사례**

**설치 및 SSH 키 설정**

yum install unison

yum install inotify-tools

users 계정으로 SSH 키 인증 설정 (비밀번호 없이 로그인 확인)

**파일 변경 감지 스크립트 작성 (users 계정으로 진행)**

vi /home/users/scripts/inotifywait.sh

#!/bin/bash

WATCH_DIR="/box/recfile"

REMOTE="ssh://users@1.1.1.1//box/recfile"

SSH_PORT=2222

LOG_FILE="/home/users/unison/inotifywait.log"

echo "$(date) Start watching $WATCH_DIR" >> $LOG_FILE

inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" | while read path action file; do

echo "$(date) Change detected: $path $action $file" >> $LOG_FILE

/usr/bin/unison "$WATCH_DIR" "$REMOTE" -batch -auto -sshargs "-p $SSH_PORT" >> $LOG_FILE 2>&1

done

**항상 스크립트가 실행되어야 하기 때문에 서비스로 등록 (root 계정으로 진행)**

**users 계정으로 스크립트가 실행되도록 설정**

vi /etc/init.d/unison-sync 

#!/bin/bash

# chkconfig: 2345 99 01

# description: inotifywait service running as users user

### BEGIN INIT INFO

# Provides:          inotifywait

# Required-Start:    $network

# Required-Stop:

# Default-Start:     2 3 4 5

# Default-Stop:      0 1 6

# Short-Description: Start inotifywait script as users user

### END INIT INFO

SCRIPT="/home/users/scripts/inotifywait.sh"

USER="users"

PIDFILE="/home/users/unison/unison-sync.pid"

start() {

echo "Starting unison-sync service..."

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then

echo "Service is already running."

return 1

fi

su - $USER -c "nohup $SCRIPT > /home/users/unison/inotifywait.log 2>&1 & echo \$! > $PIDFILE"

sleep 1

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then

echo "Service started with PID $(cat $PIDFILE)."

else

echo "Failed to start service."

return 1

fi

}

stop() {

echo "Stopping unison-sync service..."

if [ ! -f "$PIDFILE" ]; then

echo "PID file not found, service may not be running."

return 1

fi

PID=$(cat "$PIDFILE")

if kill -0 $PID 2>/dev/null; then

kill $PID

sleep 2

if kill -0 $PID 2>/dev/null; then

echo "Force killing the process..."

kill -9 $PID

fi

rm -f "$PIDFILE"

echo "Service stopped."

else

echo "Process not running, removing stale PID file."

rm -f "$PIDFILE"

fi

}

status() {

if [ -f "$PIDFILE" ]; then

PID=$(cat "$PIDFILE")

if kill -0 $PID 2>/dev/null; then

echo "Service is running with PID $PID."

return 0

else

echo "PID file exists but process is not running."

return 1

fi

else

echo "Service is not running."

return 3

fi

}

case "$1" in

start)

start

;;

stop)

stop

;;

restart)

stop

start

;;

status)

status

;;

*)

echo "Usage: $0 {start|stop|restart|status}"

exit 2

;;

esac

exit 0

**서비스 기동 확인 및 동기화 확인**

service unison-sync start

ps -ef | grep inotify

701      10294     1  0 09:13 ?        00:00:00 /bin/bash /home/users/scripts/inotifywait.sh

701      10303 10294  0 09:13 ?        00:00:00 inotifywait -m -r -e modify,create,delete,move /box/recfile

701      10304 10294  0 09:13 ?        00:00:00 /bin/bash /home/users/scripts/inotifywait.sh

root     21643 17782  0 11:25 pts/0    00:00:00 grep inotify

/box/recfile 경로에서 임의로 파일 생성 및 삭제 테스트 ( recfile 디렉토리 권한 775로 변경 )

- *기존 lsyncd 는 서비스 down 및 부팅 시 실행 안되도록chkconfig lsyncd off 설정*

**로그 (로그로테이트 적용)**

/home/users/unison.log (unison을 실행하면 기본으로 홈디렉터리에 로그가 생김)

/home/users/unison/inotifywait.log (사용자가 지정한 로그 경로)
