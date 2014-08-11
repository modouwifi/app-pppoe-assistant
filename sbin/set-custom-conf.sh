#!/bin/sh
CURDIR=$(cd $(dirname $0) && pwd)
CUSTOMCONF="$CURDIR/../conf/pppoe-custom.conf"
CUSTOMCONF_CANCEL="$CURDIR/../conf/pppoe-custom-cancel.conf"
LUABUTTON1="lua $CURDIR/../lua/catch.lua"
LUABUTTON2="lua $CURDIR/../lua/dial.lua"
HEAD='"cmd":"'
TAIL='",'
CMDBUTTON1="${HEAD}${LUABUTTON1}${TAIL}"
CMDBUTTON2="${HEAD}${LUABUTTON2}${TAIL}"

# for pppoe-custom.conf
echo '
{
"title" : "PPPoE拨号迁移助手",
"content" : "使用说明：
将您的旧路由器wan口和魔豆的lan口（黄色）用网线相连，点击下方的[开始迁移]，迁移成功完成后，点击[开始拨号]",

"button1" :  {
    "txt" : "开始迁移",
' > $CUSTOMCONF
echo $CMDBUTTON1 >> $CUSTOMCONF
echo '
    "code" : {
      "0" : "迁移成功，可以开始拨号",
      "256" : "迁移超时，请检查连线，并确保旧路由器处于拨号状态"
    }
  },

  "button2" :  {
    "txt" : "开始拨号",
' >> $CUSTOMCONF
echo $CMDBUTTON2 >> $CUSTOMCONF
echo '
    "code" : {
      "0" : "已拨号连接成功",
      "256" : "拨号连接失败，请检查帐号密码"
    }
  }
}
' >>$CUSTOMCONF

# for pppoe-custom-cancel.conf
echo '
{
"title" : "PPPoE拨号迁移助手",
"content" : "已取消",

"button1" :  {
    "txt" : "开始迁移",
' > $CUSTOMCONF_CANCEL
echo $CMDBUTTON1 >> $CUSTOMCONF_CANCEL
echo '
    "code" : {
      "0" : "迁移成功，可以开始拨号",
      "256" : "迁移超时，请检查连线，并确保旧路由器处于拨号状态"
    }
  },

  "button2" :  {
    "txt" : "开始拨号",
' >> $CUSTOMCONF_CANCEL
echo $CMDBUTTON2 >> $CUSTOMCONF_CANCEL
echo '
    "code" : {
      "0" : "已拨号连接成功",
      "256" : "拨号连接失败，请检查帐号密码"
    }
  }
}
' >>$CUSTOMCONF_CANCEL
