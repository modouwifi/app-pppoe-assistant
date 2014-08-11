#!/bin/sh
##########################################
# Use the pppoe-server for special dial

CURDIR=$(cd $(dirname $0) && pwd)

start()
{
    if [ ! -f $CURDIR/../conf/pppoe-server-options ]; then
        echo "We lost the pppoe-server-options";
        return 1;
    fi
    if [ -f /var/log/pppoe-server-log ]; then
        rm /var/log/pppoe-server-log;
    fi
    if [ ! -f /usr/sbin/pppoe ]; then
        ln -s $CURDIR/../bin/pppoe /usr/sbin/pppoe
    fi
    $CURDIR/../bin/pppoe-server -I br0 -N 10 -O $CURDIR/../conf/pppoe-server-options
    if [ "$?" != "0" ]; then
        echo "start the pppoe server failed";
        return 1;
    fi
    return 0;
}

stop()
{
    killall pppoe-server
    rm /var/log/pppoe-server-log
    return 0;
}

case "$1" in
    "start" )
        start;
        if [ "$1" != "0" ]; then
            exit 1;
        fi
        exit 0;
        ;;
    "stop" )
        stop;
        if [ "$1" != "0" ]; then
            exit 1;
        fi
        exit 0;
        ;;
    *)
        exit 1;
        ;;
esac


