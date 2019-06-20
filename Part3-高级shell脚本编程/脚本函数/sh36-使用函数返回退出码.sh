#!/bin/bash
# Program:
#   using the return command  in a  function
# History:
# 2019.06.18 chengcai	First release

#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH

#---------------------------创建函数-----------------------
function func1 {
    read -p "Enter a value: " value
    echo "This is an example of a function"
    echo "Doubling the value"
    echo $[ $value * 2  ]
}
result=`func1`
echo "The new value is $result"