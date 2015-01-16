#!/bin/bash

rpltest=`echo "show slave status\G;" | HOME=/var/lib/zabbix mysql | grep "Slave.*Running:" | awk '{print $2}' | sort -u` 

if [ "$rpltest" = "Yes" ]
then 
    echo "Replication OK"
elif [ -z "$rpltest" ]
then
    echo "Replication not found on this server" 
else
    FailedQuery=`echo "show slave status\G;" | HOME=/var/lib/zabbix mysql | grep "Last_IO_Error:" | sed "s/Last_IO_Error://g"` 
    echo "Replication Failed: $FailedQuery"
fi
