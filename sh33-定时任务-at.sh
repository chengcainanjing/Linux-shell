#!/bin/bash
# Program:
#   test using at command
# History:
# 2019.06.17 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------定时任务-at----------------------"
exec 3 > sh33out_`date +%Y%m%d_%H%M%S`.file         #重定向输出到文件中，该文件命名为日期时间
exec 1>&3                                           #将输出到显示器上的内容，重定向到文件中
echo "This script ran at ‘date +%B%d%T‘"
echo
sleep 5
exec 3>&1                                           #将之前的重定向取消，恢复输出到屏幕
exec 1>sh33out.file                                 #将屏幕的输出重定向到文件
echo "This is the script's end ..."
