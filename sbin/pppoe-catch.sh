#!/bin/sh
CURDIR=$(cd $(dirname $0) && pwd)
CONFIDR="$CURDIR/conf"
LOGFILE="/var/log/pppoe-server-log"
CATCHFILE="/tmp/catch"
CATCHCODE="/var/run/catch.code"
CATCHSTATUS="/var/run/catch.status"
CATCHPID="/var/run/catch.pid"
echo $$ > $CATCHPID;
if [ -f $CATCHCODE ]; then
    rm $CATCHCODE;
fi
touch $CATCHCODE;
if [ -f $CATCHFILE ]; then
    rm $CATCHFILE;
fi
touch $CATCHFILE;
echo "-1" > $CATCHCODE;
echo "-1" > $CATCHSTATUS;
$CURDIR/../sbin/pppoe-server.sh start;
# wait patiently for the pppoe-server start the work
while [ ! -f $LOGFILE ]; do
    sleep 1;
done

# wait patiently to get the first username
while [ "$firstUsername" == "" ]; do
    firstUsername=`cat $LOGFILE | grep "PAP AuthReq " | head -n 1 | cut -d " " -f 5 | cut -b 6-`
    sleep 1;
done
# then get the first password
firstPasswd_tmp=`cat $LOGFILE | grep "PAP AuthReq " | head -n 1`
firstPasswd=`echo ${firstPasswd_tmp##*password=} | sed 's/.$//' `;

# update the first one to the catchfile
echo $firstUsername > $CATCHFILE;
echo $firstPasswd >> $CATCHFILE;
echo "1" > $CATCHCODE;

# wait patiently for all kinds
Count=1;
DONE=0;
lines=0;
while [ "$DONE" == "0" ]; do
    let Count+=1;
    while [ $lines -lt $Count ]; do
        lines=`cat $LOGFILE | grep "PAP AuthReq " | wc -l `;
        sleep 1;
    done
    nextUsername=`cat $LOGFILE | grep "PAP AuthReq " | head -n $Count | tail -n 1 | cut -d " " -f 5 | cut -b 6-`
    nextPasswd_tmp=`cat $LOGFILE | grep "PAP AuthReq " | head -n $Count | tail -n 1 `
    nextPasswd=`echo ${nextPasswd_tmp##*password=} | sed 's/.$//' `;
    if [ "$firstUsername" == "$nextUsername" -a "$firstPasswd" == "$nextPasswd" ]; then
        DONE=1;
        echo "#ALLDONE_MODOU#" >> $CATCHFILE;
    else
        echo $nextUsername >> $CATCHFILE;
        echo $nextPasswd >> $CATCHFILE;
        echo $Count > $CATCHCODE;
    fi
done
$CURDIR/../sbin/pppoe-server.sh stop;
echo "1" > $CATCHSTATUS;
rm $CATCHPID;
exit 0;

