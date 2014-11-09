#!/usr/bin/env bash

yum -y update

#set up hostnames
echo "10.10.2.100 hadoop-master" >> /etc/hosts
echo "10.10.2.101 hadoop-slave1" >> /etc/hosts
echo "10.10.2.101 hadoop-slave2" >> /etc/hosts

#configure ssh login
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@hadoop-master
ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@hadoop-slave1
ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@hadoop-slave2
chmod 0600 ~/.ssh/authorized_keys

#install oracle java
wget -O /opt/jdk-7u67-linux-x64.tar.gz --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-linux-x64.tar.gz"
tar xzf /opt/jdk-7u67-linux-x64.tar.gz -C /opt/
touch /etc/profile.d/java.sh
echo "export JAVA_HOME=/opt/jdk1.7.0_67" >> /etc/profile.d/java.sh
echo "export JRE_HOME=/opt/jdk1.7.0_67/jre" >> /etc/profile.d/java.sh
#create symbolic link-- Init script for elasticsearch- needs java to be in standard env location
ln -s /opt/jdk1.7.0_67/bin/java /bin/java

#download hadoop
mkdir /opt/hadoop
wget -P ~/ http://www.trieuvan.com/apache/hadoop/common/hadoop-2.2.0/hadoop-2.2.0.tar.gz
tar xzf hadoop-2.2.0.tar.gz
mv hadoop-2.2.0 hadoop

#set up env variables
touch /etc/profile.d/hadoop.sh
echo "export PATH=$PATH:/opt/jdk1.7.0_67/bin:/opt/jdk1.7.0_67/jre/bin:$HOME/hadoop/bin:$HOME/hadoop/sbin" >> /etc/profile.d/hadoop.sh
echo "export HADOOP_PREFIX=$HOME/hadoop" >> /etc/profile.d/hadoop.sh 
echo "export HADOOP_MAPRED_HOME=$HOME/hadoop" >> /etc/profile.d/hadoop.sh 
echo "export HADOOP_COMMON_HOME=$HOME/hadoop" >> /etc/profile.d/hadoop.sh
echo "export HADOOP_HDFS_HOME=$HOME/hadoop" >> /etc/profile.d/hadoop.sh
echo "export HADOOP_YARN_HOME=$HOME/hadoop" >> /etc/profile.d/hadoop.sh
echo "export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop" >> /etc/profile.d/hadoop.sh
echo "export YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop" >> /etc/profile.d/hadoop.sh 
 
#set up config
CONF1="<configuration>
<property>
    <name>fs.default.name</name>
    <value>hdfs://master:9000</value>
</property>
<property>
    <name>hadoop.tmp.dir</name>
    <value>path/to/hadoop/tmp</value>
</property>
</configuration>"
sed -i "s/<configuration>/ /" ~/hadoop/etc/hadoop/core-site.xml
sed -i "s/</configuration>/ /" ~/hadoop/etc/hadoop/core-site.xml
echo "$CONF1" >> ~/hadoop/etc/hadoop/core-site.xml

CONF2="<configuration>
<property>
    <name>dfs.replication</name>
    <value>2</value>
    <description>you can set your own replica size</description>
</property>
<property>
    <name>dfs.permissions</name>
    <value>false</value>
</property>
<property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
</property>
</configuration>"
sed -i "s/<configuration>/ /" ~/hadoop/etc/hadoop/hdfs-site.xml
sed -i "s/</configuration>/ /" ~/hadoop/etc/hadoop/hdfs-site.xml
echo "$CONF2" >> ~/hadoop/etc/hadoop/hdfs-site.xml   

CONF3="<configuration>
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
<property>
    <name>yarn.resourcemanager.resource-tracker.address</name>
    <value>master:8025</value>
</property>
<property>
    <name>yarn.resourcemanager.scheduler.address</name>
    <value>master:8030</value>
</property>
<property>
    <name>yarn.resourcemanager.address</name>
    <value>master:8040</value>
</property>
</configuration>"
sed -i "s/<configuration>/ /" ~/hadoop/etc/hadoop/yarn-site.xml
sed -i "s/</configuration>/ /" ~/hadoop/etc/hadoop/yarn-site.xml
echo "$CONF3" >> ~/hadoop/etc/hadoop/yarn-site.xml  

CONF4="<configuration>
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
<property>
    <name>mapreduce.jobhistory.address</name>
    <value>master:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>master:19888</value>
</property>
</configuration>"
sed -i "s/<configuration>/ /" ~/hadoop/etc/hadoop/mapred-site.xml
sed -i "s/</configuration>/ /" ~/hadoop/etc/hadoop/mapred-site.xml
echo "$CONF3" >> ~/hadoop/etc/hadoop/mapred-site.xml  

hdfs namenode -format
 




