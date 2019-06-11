#!/bin/bash
# Program:
#	变量的使用
# History:
# 2019.06.11 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

test1=`date`
echo $test1

test2=$(date)
echo $test2