#!/bin/bash
# Program:
#   using recursion
# History:
# 2019.06.20 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------阶乘函数-----------------------
function factorial() {
    if [ $1 -eq 1 ]; then
        echo 1
    else
        local temp=$[ $1 - 1 ]
        local result=`factorial $temp`
        echo $[ $result * $1 ]
    fi
}

#--------------------------------------------------------
read -p "Please input a value: " value
#向阶乘函数传参，返回最后值
result=`factorial $value`
echo "The factorial of $value is :  $result"
