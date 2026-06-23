* 스크립트 자동 입력 sh

#!/usr/bin/expect

expect << EOF
set timeout 60

spawn /home/user/install/./jeus7_unix_generic_ko.bin
expect "CONTINUE:"
sleep 1
send "\n"
expect "CONTINUE:"
sleep 1
send "\n"
expect "CONTINUE:"
sleep 1
send "\n"
expect "AGREEMENT?"
sleep 1
send "Y\n"
expect "(DEFAULT: 9)"
sleep 1
send "9\n"
expect "ABSOLUTE PATH"
sleep 1
send "/data/webapps/JEUS7\n"
expect "/data/webapps/JEUS7"
sleep 1
send "Y\n"
expect "INSTALL"
sleep 1
send "1\n"
expect "DESIRED"
sleep 1
send "1\n"
expect "JDK"
sleep 1
send "/usr/java/jdk1.8.0_281\n"
expect "Password"
sleep 2
send "jeusadmin\n"
expect "Corfirm"
sleep 2
send "jeusadmin\n"
expect "domain"
sleep 1
send "test_domain\n"
expect "CHOICE"
sleep 1
send "1\n"
expect "CONTINUE"
sleep 1
send "\n"
expect "CONTINUE"
send "\r"
sleep 1
expect "INSTALLER"
sleep 1
send "\r"
expect eof
