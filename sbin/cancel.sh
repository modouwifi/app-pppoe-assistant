#!/bin/sh
CURDIR=$(cd $(dirname $0) && pwd)
PIDFILE="$CURDIR/../custom.pid"
pid=`cat $PIDFILE 2>/dev/null`;
kill -9 $pid >/dev/null 2>&1;
$CURDIR/../sbin/pppoe-catch-clear.sh
custom $CURDIR/../conf/pppoe-custom-cancel.conf&
echo $! > $PIDFILE
