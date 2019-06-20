#!/bin/bash
# Program:
#   using functions defind in a library file
# History:
# 2019.06.20 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------公共使用函数-----------------------
#使用库函数的关键是source 命令，source命令会在当前shell上下文中执行命令，而不是创建一个新shell
#source命令，有个快捷的别名，称作点操作符（dot operator）
#source ./sh41myfuncs.sh
. ./sh41myfuncs.sh
#------------------------------------------------------------
value1=4
value2=3
result1=`addem $value1 $value2`
result2=`multem $value1 $value2`
result3=`divem $value1 $value2`
echo "The result of adding them is : $result1"
echo "The result of multiplying them is : $result2"
echo "The result of dividing them is : $result3"
