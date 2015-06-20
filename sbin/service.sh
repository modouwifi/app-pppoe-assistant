#!/bin/sh

PWD="$(cd $(dirname $0) && pwd)"
ROOT="$PWD/.."
book="/var/run/pppoe-pass"

BR="
"

. /lib/functions/app.sh

start() {
    rm $book
    
    [ ! -f /usr/sbin/pppoe ] && ln -s "$ROOT/bin/pppoe" /usr/sbin
    [ ! -f /usr/sbin/pppd-modou ] && ln -s "$ROOT/bin/pppd-modou" /usr/sbin
    [ ! -f /etc/ppp/password_hook.sh ] && ln -s "$PWD/password_hook.sh" /etc/ppp

    $ROOT/bin/pppoe-server -I br-lan -N 100 -O "$ROOT/conf/pppoe-server-options"

    start_loading "等待截取帐号信息"
}

stop() {
    rm /usr/sbin/pppoe
    rm /usr/sbin/pppd-modou
    rm /etc/ppp/password_hook.sh
    
    killall pppoe-server
}

dial() {
    stop

    while read line
    do
        local name=`echo "$line" | awk '{print $1}'`
        local pass=`echo "$line" | awk '{print $2}'`
        echo "name($name) pass($pass)"

        start_loading "尝试($name).."

        pppd updetach nodefaultroute usepeerdns maxfail 3 \
            user "$name" password "$pass" mtu 1400 mru 1400 \
            plugin rp-pppoe.so nic-eth0.2 debug

        if [ "$?" == 0 ] ; then
            correct_account_found "$name" "$pass"
            return 
        fi
    done < $book

    prompt 没有帐号可以连接通网络! &
    finish_loading
}

correct_account_found() {
    local name="$1"
    local pass="$2"

    killall pppd

    finish_loading
    start_loading "正在用($name)接互联网.." 
    
    #start_loading "正在连接互联网..."
    lua /system/share/lua/5.1/tp_entry.lua wan_api.set_config "{\"account\":\"$name\",\"password\":\"$pass\",\"type\":\"pppoe\"}"
    
    prompt "迁移成功!" &
    finish_loading
}



case "$1" in 
    "start")
        start;;
    "stop")
        stop;;
    "dial")
        dial;;
    *)
        ;;
esac