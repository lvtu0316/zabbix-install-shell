# zabbix-install-shell
### 介绍

此脚本为 zabbix 源码编译一键安装脚本，默认你已经安装好了 LNMP 环境，和 net-snmp。

如果 LNMP 环境没有安装，可以选择[lnmp](https://lnmp.org/install.html) 一键安装脚本进行安装。

zabbix-nginx.conf 为 nginx 配置文件，监听端口可以根据自己更改。

msyh.ttf 为微软雅黑字体。

### 脚本使用

使用前需要下载 [zabbix](https://www.zabbix.com/download_sources )源码包，

确认mysql_config 位置，如果mysql为默认安装，则为/usr/bin/mysql_config；

确认net-snmp-config位置，默认安装为/usr/bin/net-snmp-config；

修脚本中mysql_config、net-snmp-config变量。

修改脚本中mysql root用户密码。

执行脚本安装。

安装完成访问 $IP 地址，默认账户： admin；密码：zabbix；

