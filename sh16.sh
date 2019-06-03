#!/bin/bash
# Program:
#	Use id, finger command to check system account's information.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

users=$(cut -d ':' -f1 finger /etc/passwd)     #获取账号名称
for username in $users                  #开始循环进行
