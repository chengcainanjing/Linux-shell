#!/bin/bash
# Program:
#	test命令：2、字符串比較
# History:
# 2019.06.11 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

str1=baseball
str2=hockey

if [ $str1 \> $str2 ]; then             #正確執行該條命令，需要在大於號前加上转义字符，如果不加转义字符，会重定向输出一个文档hockey
    echo "$str1 is greater than $str2"
else
    echo "$str1 is less than $str2"
fi

str3=testing
str4=''

if [ -n $str3 ]; then
    echo "The string '$str3' is not empty"
else
    echo "The string '$str3' is empty"
fi

if [ -z $str4 ]; then
    echo "The string '$str4' is not empty"
else
    echo "The string '$str4' is empty"
fi