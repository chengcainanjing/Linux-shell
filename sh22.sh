#!/bin/bash
# Program:
#	using an alternative file descriptor
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------创建输出文件描述符----------------------"
exec 3>sh22.outfile             #exec命令将文件描述符3重定向到另一个文件
#exec 3>>sh22.outfile             #exec命令将文件描述符3重定向追加到一个现有的文件

echo "This should display on the monitor."
echo "and this should be stored in the file" >&3        #>&3 表示重定向文件描述符3的这行输出进入另一个文件
echo "Then this should be back on the monitor"

