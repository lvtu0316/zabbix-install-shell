#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install "
    exit 1
fi
cur_dir=$(pwd)
read -p  "what's zabbix-server-IP ?:" ServerIP
echo "创建zabbix用户"
groupadd zabbix
useradd -g zabbix zabbix

mkdir /usr/local/agentd
tar -zxvf zabbix_agents-4.0.15-linux3.0-amd64-static.tar.gz -C /usr/local/agentd
cd /usr/local/agentd
cp $cur_dir/zabbix_agentd /etc/init.d/
chmod +x /etc/init.d/zabbix_agentd
chkconfig --add zabbix_agentd
chkconfig zabbix_agentd on
sed -i "s/Server=127.0.0.1/Server=$ServerIP/g" /usr/local/agentd/conf/zabbix_agentd.conf
service zabbix_agentd restart