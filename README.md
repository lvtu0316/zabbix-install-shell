# zabbix-install-shell
此脚本为 zabbix 源码编译一键安装脚本，默认你已经安装好了 LNMP 环境，和 net-snmp。

如果 LNMP 环境没有安装，可以选择[lnmp](https://lnmp.org/install.html) 一键安装脚本进行安装。

### 脚本使用

使用前需要下载 [zabbix](https://www.zabbix.com/download_sources )源码包，

确认mysql_config 位置，如果mysql为默认安装，则为/usr/bin/mysql_config；

确认net-snmp-config位置，默认安装为/usr/bin/net-snmp-config；

修脚本中mysql_config、net-snmp-config变量。

执行脚本安装。