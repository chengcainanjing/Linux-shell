#!/bin/bash
# Program:
#	test命令：3、文件比较
# History:
# 2019.06.11 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

dir=/home/cc
if [ -d  $dir ]; then
    echo "The $dir directory exists"
    cd $dir
    ls
else
    echo "The $dir directory does not exist"
fi