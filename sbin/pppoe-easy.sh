#!/bin/sh

###################################
# easy to kill the pppd and start it again

killall pppd
pppmtu=`nvram_get 2860 PPPMTU`
[ "$pppmtu" == "" ] && pppmtu=1400;
pppd debug file /etc/options.pppoe mtu $pppmtu&
exit 0;
