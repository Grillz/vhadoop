#!/usr/bin/env bash

yum -y update

#get vim
yum install vim
echo "syntax on" > .vimrc

#install oracle java
wget -O /opt/jdk-7u67-linux-x64.tar.gz --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-linux-x64.tar.gz"
tar xzf /opt/jdk-7u67-linux-x64.tar.gz -C /opt/
touch /etc/profile.d/java.sh
echo "export JAVA_HOME=/opt/jdk1.7.0_67" >> /etc/profile.d/java.sh
echo "export JRE_HOME=/opt/jdk1.7.0_67/jre" >> /etc/profile.d/java.sh
echo "export PATH=$PATH:/opt/jdk1.7.0_67/bin:/opt/jdk1.7.0_67/jre/bin" >> /etc/profile.d/java.sh
#create symbolic link-- Init script for elasticsearch- needs java to be in standard env location
ln -s /opt/jdk1.7.0_67/bin/java /bin/java

