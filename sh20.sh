#!/bin/bash
# Program:
#	脚本中重定向：
#       1、临时重定向
#       2、永久重定向脚本中的所有命令
# History:
# 2019.06.11 chengcai	First release
#临时重定向需要输入:./sh20.sh 2> error.file

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------临时重定向----------------------"
echo "This is an error output" >&2
echo "This is normal output"

echo "-----------------------永久重定向-----------------------"
exec 2>sh20-testerror                                       #exec命令告诉shell在脚本执行期间重定向某个特定文件描述符
echo "This is the start of  the script"
echo "now redirecting all output to another location"

exec 1>sh20-testout
echo "This output should go to the testout file"
echo "but this should go to the testerror file" >&2         #>&2 单独将一行输出重定向到STDERR
echo "This output should also go to the testout file" 2>&1  #2>&1 将错误与输出重定向到一个文件中