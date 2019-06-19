#!/bin/bash
# Program:
#   demonstrating the local keyword
#   using a global variable to pass a value
# History:
# 2019.06.18 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------创建函数-全局变量-----------------------
function gloabl_variable {
    value_1=$[ $value_1 * 2 ]
    echo "The value of the glocal_variable is $value_1"
}

value_1=4
read -p "Enter a value:" value_1
gloabl_variable
echo "The new value is :$value_1"

#---------------------------创建函数-局部变量-----------------------
function local_variable {
    local temp=$[ $temp + 5 ]                           #局部变量使用local 变量名
    echo "The value of the local_variable is $temp"
    result=$[ $temp + 2 ]
}

value_2=6
temp=5

local_variable
if [ $temp -gt $value_2 ]; then
    echo "temp is lager"
else
    echo "temp is smaller"
fi

echo "The value of the temp is: $temp"

