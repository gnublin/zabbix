#!/bin/bash
PATH=$PATH:/etc/zabbix/externalscripts:/opt/zabbix/externalscripts:/opt/zabbix/bin:/home/zabbix/bin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
export PATH
BASE_DIR="`dirname $0`"
/usr/bin/ruby $BASE_DIR/redis.rb $* 
echo 0
