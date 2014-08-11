#!/bin/sh
##################################################
# update the username and passwd the options.pppoe 
if [ ! -n "$2" ]; then
    exit 1;
fi
PPPOEFILE=/etc/options.pppoe
if [ ! -f $PPPOEFILE ]; then
    exit 1;
fi
sed -i  /user/d $PPPOEFILE
sed -i  /password/d $PPPOEFILE
echo "user '$1'" >> $PPPOEFILE
echo "password '$2'" >> $PPPOEFILE
exit 0;
