#!/usr/bin/env bash

if [ ! -f "/etc/rebooted" ]; then
# update / upgrade
apt-get -y update && apt-get -y upgrade

# install required packages
apt-get install -y vim python-pip nano

#config ssh
sed '/Port 22/'d /etc/ssh//sshd_config -i
sed -e "/4/a Port 1222" -i /etc/ssh//sshd_config

service ssh restart

# Install SS
pip install shadowsocks

if [ -f "/etc/shadowsocks.json" ]; then 
rm /etc/shadowsocks.json
fi
ipaddress=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6 | awk '{print $2}' | tr -d "addr:")
echo "{" > /etc/shadowsocks.json
echo "  \"server\":\"$ipaddress\"," >> /etc/shadowsocks.json
echo "  \"server_port\":9999," >> /etc/shadowsocks.json
echo "  \"local_port\":1080," >> /etc/shadowsocks.json
echo "  \"password\":\"pass\"," >> /etc/shadowsocks.json
echo "  \"timeout\":600," >> /etc/shadowsocks.json
echo "  \"method\":\"rc4-md5\"" >> /etc/shadowsocks.json
echo "}" >> /etc/shadowsocks.json

# atuo start
sed -i '$i\/usr/local/bin/ssserver -c /etc/shadowsocks.json' /etc/rc.local

# Change kernel
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9/linux-image-4.9.0-040900-generic_4.9.0-040900.201612111631_amd64.deb
dpkg -i linux-image-4.9.0*.deb
update-grub
touch /etc/rebooted
reboot
fi

echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
sysctl net.ipv4.tcp_available_congestion_control
lsmod | grep bbr
ulimit -n 51200
