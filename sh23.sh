#!/bin/bash
# Program:
#	storing STDOUT, then coming back to it
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------重定向文件描述符----------------------"
exec 3>&1                           #将输出到显示器上的内容重定向到STDOUT
exec 1>sh23.outfile                 #将STDOUT的输出重定向到文件sh23.outfile

echo "This should store in the output file"
echo "alone with this line"

exec 1>&3                           #文件描述符3的输出重定向出现在显示器上

echo "Now things should be back to normal"
