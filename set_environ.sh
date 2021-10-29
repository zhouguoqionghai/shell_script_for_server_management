#!/bin/bash


shell_ppid=$PPID  #直接使用环境变量来获取
# 父进程是否是 bash

if [ ! -d /proc/${shell_ppid} ]; then
	echo "parent bash";  ##如果父进程的 pid id为 1，在 msys2 中，实际是没有pid为1的进程的。
else
	ls /proc/${shell_ppid}/exe -lha | grep "/usr/bin/bash" > /dev/null #管道的返回值是最后一个命令的返回值, pipefail 如果有设置，就是最后一个返回值不为 0 的命令
	if [ $? -ne 0 ]; then 
		echo "parent bash";  ##父bash
	else
		echo "child bash, no ssh-agent check" ## 子bash，不进行 shell 检查
		return 0 # 只能用 return， 用 exit 会导致使用 source 调用该脚本时，子 shell 直接退出
	fi
fi

ps | grep ssh-agent > /dev/null
if [ $? -ne 0 ]; then
	echo "ssh-agent is not running, so start it!"
	ssh-agent > ~/ssh_agent_var.sh
	
	source ~/ssh_agent_var.sh

	ssh-add /d/Identity_Linux #这里指定私钥文件
else
	echo "ssh-agent is already running!"
	source ~/ssh_agent_var.sh
fi