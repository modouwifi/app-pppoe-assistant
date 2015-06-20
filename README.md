pppoe-assistant
===============

## 运行在魔豆路由器上的PPPOE迁移助手应用

    * PPPoE拨号账号迁移助手，简单完成新老路由的交接工作。

## 功能

    * 一键将老路由器中的PPPOE账号密码转移到魔豆路由器上；
    * 可拔脱某些地区运营商的“特殊拨号”限制。

## 安装方法

    * 在modou屏幕上点击打开［极客模式］；
    * 在浏览器上输入modouwifi.net和相应密码，进入web管理界面；
    * 进入web管理下的［应用］界面，上传安装本应用便可。
    * 直接从魔豆应用市场安装即可。

## 系统要求

    * 稳定版 1.7及以上；
    * 开发版 1.7.04及以上；

## 使用方法

    * 应用安装成功之后，在魔豆屏幕上将多出一个［账号迁移助手］的图标，点击打开该应用；
    * 将您的老路由器的WAN口和魔豆的任何一个LAN口(黄色)用网线连接；
    * 让老路由器开始PPPoE拨号；
    * 点击应用上的［开始迁移］按钮，等待迁移成功；
    * 迁移成功之后，点击［开始拨号］，等待拨号结束便可。

## 开发计划

    * 添加在路由宝上的操作支持
    * 添加更多的运营商支持




# 编译备忘

    * pppoe-server 从 rp-pppoe-3.8 源码包编译,为了让pppd能够记录用户的帐号密码，我们需要修改pppd源码，而又不想和系统的pppd起冲突，所以修改pppoe-server调用的pppd为pppd-modou,具体步骤为下：

    修改src/pppoe-server.c, 将startPPPDUserMode 和 startPPPDLinuxKernelMode 中调用的 "pppd" 都修改成"pppd-modou", 修改Makefile   修改 PPPD_PATH=$(sbindir)/pppd-modou(或者在configure 中指定)

    * pppoe 也是从rp-pppoe-3.8 中编译,但不知道为什么用sdk的工具链编译出来的pppoe，运行时会有"can't resolv __sysv_signal"的错误, 而将rp-pppoe-3.8放到openwrt的编译环境中才能编译成功.

    * pppd 从 pppd-2.4.6中编译,修改auth.c
    在check_passwd函数中添加
    char buf[256] ;
    
    snprintf(buf, sizeof(buf), "/etc/ppp/password_hook.sh %s %s", user, passwd) ;
    system(buf) ;


    









