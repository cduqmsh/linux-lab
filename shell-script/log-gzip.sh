* 로그 압축 스크립트

#!/bin/sh

#LOGDIR=/logs/mydata/2022-02
#GZIP_DAY=2

LOGMonth=$(date +%Y-%m) # 해당 월의 디렉터리로 이동
LOGDIR=/logs/mydata/$LogMonth
GZIP_DAY=2

cd $LOGDIR
echo "cd $LOGDIR"

## GZIP Action
/usr/bind/find . -type f -name "application.*" -mtime +$GZIP_DAY -exec /usr/bin/gzip {} \; 2> /dev/null
/usr/bind/find . -type f -name "applog.*" -mtime +$GZIP_DAY -exec /usr/bin/gzip {} \; 2> /dev/null
