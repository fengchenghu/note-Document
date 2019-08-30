### 远程ssh在集群内其他机器执行命令，需要有ssh免密登录权限
	ssh 机器ip（user@ip） 'free -g  (执行的命令)'
### 获取机器执行命令后的输出第一列，得到的是字符串
	str=`kubectl get node | grep tjtx |  awk '{print $1}' `
### 按指定字符分割字符串为数组
	arr=(${str//(分隔符)/ （这个位置有空格）})
### 遍历数组for循环
	for i in ${arr[@]}  
	do
		echo "$i"
	done  
	
### 执行scp 拷贝远程文件
	scp -r 远程主机IP:/opt/log/wcs_errorquery/ ./目标路径
	
### docker容器执行crontab 定时任务
	crontab 文件名  会将原来的任务替换掉    不可这样操作   务必小心    
	crontab 任务的日志在/var/log/cron
```
	#install cronie
	RUN yum -y install cronie \				安装crontab
    && yum -y install crontabs \
	&& yum -y install rsyslog \				安装日志工具
    && chmod +x /home/application/test.sh \
    && chmod +x /home/application/start.sh
	
	start.sh	启动crontab 服务和rsyslogd服务
		#!/bin/bash
		rsyslogd						启动rsyslog  接收日志
		/usr/sbin/crond -i				启动crontab
		sleep 5
		crontab /home/application/crontask.cron
		
	crontask.cron
		*/1 * * * * 执行的任务
```
### shell下按指定行数切割文件
	split -l 指定行数 待切割的文件.log -d -a (数字，指定要以几位数字结尾 默认用 aa ab结尾) data_(新生成的文件名前缀)
### shell找到一个进程的pid
	ps -ef |grep 进程名 |grep -v grep |awk '{print $2}'
	grep -v grep： 过滤当前这个命令的进程名字符串
	awk '{print $2}： 第二列为pid
### /usr/bin/killall -0 进程名   
    exsit="killall -0 A;echo $?"
    exsit为0就表示进程A存在，否则表示不存在。
    当有多个进程名字都是A的时候，只有在全部名字为A的进程都退出后，exsit才非0，所以这种监控方法并不太适合多进程环境