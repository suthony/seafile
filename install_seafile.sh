#!/bin/bash
################ 一键安装Seafile脚本 ##################
#Author:xiaoz.me
#######################   END   #######################

#防火墙放行端口
function chk_firewall() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
		iptables -I INPUT -p tcp --dport 8082 -j ACCEPT
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --add-port=8000/tcp --permanent
		firewall-cmd --zone=public --add-port=8082/tcp --permanent
		firewall-cmd --reload
	fi
}

#安装seafile函数
function install_sea() {
	cd /home/MyCloud
	#下载安装包6.0.9 64bit
	wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_6.1.8_x86-64.tar.gz&dl=1" -O seafile-pro-server_6.1.8_x86-64.tar.gz
	#解压
	tar -zxvf seafile-pro-server_6.1.8_x86-64.tar.gz
	mkdir installed
	mv seafile-pro-server_6.1.8_x86-64.tar.gz ./installed
	mv seafile-pro-server_6.1.8_x86-64.tar.gz seafile-server
	#安装依赖环境
	yum -y install python-setuptools python-imaging python-ldap MySQL-python python-memcached python-urllib3 jre
	#进行安装
	cd seafile-pro-server-6.1.8 && ./setup-seafile.sh
	
	#启动服务
	./seafile.sh start &&  ./seahub.sh start
	#防火墙放行端口
	chk_firewall
	#获取IP
	osip=$(curl http://https.tn/ip/myip.php?type=onlyip)
	echo "恭喜，安装完成。请访问：http://${osip}:8000"
	echo "帮助文档请访问：https://www.xiaoz.me/archives/8480"
}

echo "##########	欢迎使用Seafile一键安装脚本^_^	##########"

echo "1.安装Seafile"
echo "2.卸载Seafile"
echo "3.退出"
declare -i stype
read -p "请输入选项:（1.2.3）:" stype

if [ "$stype" == 1 ]
	then
		#检查目录是否存在
		if [ -e "/home/MyCloud" ]
			then
			echo "目录存在，请检查是否已经安装。"
			exit
		else
			echo "目录不存在，创建目录..."
			mkdir -p /home/MyCloud
			#执行安装函数
			install_sea
		fi
	elif [ "$stype" == 2 ]
		then
			/home/MyCloud/seafile-server/seafile.sh stop
			/home/MyCloud/seafile-server/seahub.sh stop
			rm -rf /home/MyCloud
			rm -rf /tmp/seahub_cache/*
			echo '卸载完成.'
			exit
	elif [ "$stype" == 3 ]
		then
			exit
	else
		echo "参数错误！"
	fi	
