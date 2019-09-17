#!/bin/bash
# Program:
#       位置参数
# History:
# 2019.08.23 chengcai	First release
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
################### Main Script ############################
#
############################################################
# BACKUPFILE=backup-$(date +%m-%d-%Y)
#
MINPARAMS=10

echo "The name of this script is \"$0\"."
# 附带./代表当前目录

echo "The name of this script is \"`basename $0`\"."
# 除去路径信息

if [ -n "$1" ]; then
    echo "Parameter #1 is $1"   #使用引号转义
fi

if [ -n "$2" ]; then
    echo "Parameter #2 is $2"   #使用引号转义
fi

if [ -n "$3" ]; then
    echo "Parameter #3 is $3"   #使用引号转义
fi

if [ -n "$4" ]; then
    echo "Parameter #4 is $4"   #使用引号转义
fi

if [ -n "$5" ]; then
    echo "Parameter #5 is $5"   #使用引号转义
fi

if [ -n "$6" ]; then
    echo "Parameter #6 is $6"   #使用引号转义
fi

if [ -n "$7" ]; then
    echo "Parameter #7 is $7"   #使用引号转义
fi

if [ -n "$8" ]; then
    echo "Parameter #8 is $8"   #使用引号转义
fi

if [ -n "$9" ]; then
    echo "Parameter #9 is $9"   #使用引号转义
fi

if [ -n "${10}" ]; then
    echo "Parameter #10 is ${10}"   #大于$9的参数必须被放在大括号中
fi

echo "----------------------------------------------"
echo "All the command-line parameters are : "$*""

if [ $# -lt "$MINPARAMS" ]; then
    echo
    echo "This script needs at least $MINPARAMS command-line arguments"
fi

echo

exit 0












