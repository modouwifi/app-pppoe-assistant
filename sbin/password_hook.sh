#!/bin/sh

name="$1"
pass="$2"
BR="
"

. /lib/functions/app.sh

file_name=`readlink $0`
sbin_path=`dirname $file_name`

book="/var/run/pppoe-pass"

logger -t pppoe-modou "pppoe name($name) pass($pass)"

local line=`cat $book | awk '{print $1}' | awk '$1=='''\"$1\"''' {print $1}' | wc -l`
if [ "$line" == 0 ] ; then
    echo "$name $pass" >> $book

    local num=`cat $book | wc -l`
    set_loading_txt "截取到第$num个用户($name)."
    
else
    # 停止截取
    $sbin_path/service.sh stop

    logger -t pppoe-modou "duplicated account found"
    logger -t pppoe-modou "catch password finished"

    local num=`cat $book | wc -l`

    finish_loading
    prompt "截取到$num个帐号信息.$BR点击\"确定\"以连接互联网."

    $sbin_path/service.sh dial
fi

