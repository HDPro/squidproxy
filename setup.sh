#!/bin/bash

random_user() {
	NUMERIC_CHAR=`perl -le 'print int(rand(99))'`;
	USER_START=`perl -le "print map+(A..Z,a..z,0..9)[rand 62],0..4"`;
	USER_END=`perl -le "print map+(A..Z,a..z,0..9)[rand 62],0..4"`;
	USER=${USER_START}${NUMERIC_CHAR}${USER_END}
	echo $USER
}

random_pass() {
	PASS_LEN=`perl -le 'print int(rand(6))+9'`
	START_LEN=`perl -le 'print int(rand(8))+1'`
	END_LEN=$(expr ${PASS_LEN} - ${START_LEN})
	SPECIAL_CHAR=`perl -le 'print map { (qw{@ ^ _ - /})[rand 6] } 1'`;
	NUMERIC_CHAR=`perl -le 'print int(rand(10))'`;
	PASS_START=`perl -le "print map+(A..Z,a..z,0..9)[rand 62],0..$START_LEN"`;
	PASS_END=`perl -le "print map+(A..Z,a..z,0..9)[rand 62],0..$END_LEN"`;
	PASS=${PASS_START}${SPECIAL_CHAR}${NUMERIC_CHAR}${PASS_END}
	echo $PASS
}

USERNAME=`random_user`
PASSWORD=`random_pass`
IP=`wget -q -O - http://myip.directadmin.com`
PORT=16996
CONF=/etc/squid/squid.conf

if [ ! -f ${CONF} ]; then
	# DOWNLOAD AND INSTALL
	wget https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh -O install.sh
	bash install.sh

	# CHANGE PORT
	sed -i 's/^http_port.*$/http_port '${PORT}'/g' ${CONF}
	firewall-cmd --zone=public --permanent --add-port=${PORT}/tcp > /dev/null 2>&1
	firewall-cmd --reload > /dev/null 2>&1
fi

# ADD ACCOUNT AND RESTART SQUID
sudo /usr/bin/htpasswd -b -c /etc/squid/passwd ${USERNAME} ${PASSWORD} > /dev/null 2>&1
systemctl reload squid > /dev/null 2>&1
systemctl restart squid > /dev/null 2>&1

# PRINT INFO
echo "Success!"
echo "${IP}:${PORT}:${USERNAME}:${PASSWORD}"