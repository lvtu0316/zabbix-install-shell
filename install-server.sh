#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install "
    exit 1
fi
#确认mysql_config 位置，如果mysql为默认安装，则为/usr/bin/mysql_config
mysql_config=/usr/local/mysql/bin/mysql_config
#确认net-snmp-config位置，默认安装为/usr/bin/net-snmp-config
net-snmp-config=/usr/local/net-snmp/bin/net-snmp-config
#安装zabbix-server
groupadd zabbix
useradd -g zabbix zabbix

echo "创建zabbix数据库，和用户名密码"
echo "create database IF NOT EXISTS zabbix default charset utf8 COLLATE utf8_general_ci;" | mysql -uroot -pAdmin@123

#根据下载文件修改
tar -zxvf zabbix-4.0.15.tar.gz
cd zabbix-4.0.15
./configure --prefix=/usr/local/zabbix/ --enable-server --enable-agent --with-mysql=$mysql_config --with-net-snmp=$net-snmp-config --with-libcurl --with-libxml2

make
make install

if [ $? -ne 0 ]; then
	    echo "failed"
	        exit
	else
		    echo "succeed"
fi

#添加环境变量
sed -i '$a\PATH=$PATH:/usr/local/zabbix/sbin' /etc/profile

source /etc/profile

echo "导入zabbix数据库"
mysql -uroot -pAdmin@123 -hlocalhost zabbix < database/mysql/schema.sql
mysql -uroot -pAdmin@123 -hlocalhost zabbix < database/mysql/images.sql
mysql -uroot -pAdmin@123 -hlocalhost zabbix < database/mysql/data.sql

echo "加入服务并设置开机自启动"

cp misc/init.d/tru64/zabbix_agentd /etc/init.d/
cp misc/init.d/tru64/zabbix_server /etc/init.d/
chmod +x /etc/init.d/zabbix_*


sed -i 's#DAEMON=/usr/local/sbin/zabbix_server#DAEMON=/usr/local/zabbix/sbin/zabbix_server#g' /etc/init.d/zabbix_server
sed -i 's#DAEMON=/usr/local/sbin/zabbix_agentd#DAEMON=/usr/local/zabbix/sbin/zabbix_agentd#g' /etc/init.d/zabbix_agentd


echo "查看和编辑配置文件"
sed -i 's#DBUser=zabbix#DBUser=root#g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i '/# DBPassword=/a\DBPassword=Admin@123' /usr/local/zabbix/etc/zabbix_server.conf
sed -i '1a \#chkconfig: 345 95 95' /etc/init.d/zabbix_server
sed -i '2a \##description: Zabbix_Server' /etc/init.d/zabbix_server
sed -i '1a \#chkconfig: 345 95 95' /etc/init.d/zabbix_agentd
sed -i '2a \##description: Zabbix_Server' /etc/init.d/zabbix_agentd

chkconfig --add zabbix_server
chkconfig --add zabbix_agentd
chkconfig zabbix_server on
chkconfig zabbix_agentd on

echo "创建frontend"
mkdir /home/wwwroot/zabbix
cp frontends/php/* /home/wwwroot/zabbix -R

echo "创建zabbix数据库配置档"
cat > /home/wwwroot/zabbix/conf/zabbix.conf.php <<END
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'root';
\$DB['PASSWORD'] = 'Admin@123';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = '';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
END

#复制微软雅黑字体，修改支持中文
cp msyh.ttf /home/wwwroot/zabbix/assets/fonts/
cp zabbix-nginx.conf /usr/local/nginx/conf/vhost
nginx -s reload

