#!/bin/sh
CATCHPID="/var/run/catch.pid";
pid=`cat $CATCHPID 2>/dev/null`;
kill -9 $pid >/dev/null 2>&1;
rm $CATCHPID >/dev/null 2>&1;
killall pppoe-server > /dev/null 2>&1
rm /var/log/pppoe-server-log >/dev/null 2>&1
#rm /var/run/catch.status >/dev/null 2>&1;
echo 0 > /var/run/catch.status
rm /var/run/catch.code >/dev/null 2>&1;
exit 0;
