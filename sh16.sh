#!/bin/bash
# Program:
#	Use id, finger command to check system account's information.
# History:
# 2019.06.01 chengcai	First release
#test ok in Linux-centos7
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/etc/selinux/targeted/active/modules/100/finger
export PATH

users=$(cut -d ':' -f1  /etc/passwd)     #获取账号名称
for username in $users                  #开始循环进行
do
    id $username
    finger $username
done