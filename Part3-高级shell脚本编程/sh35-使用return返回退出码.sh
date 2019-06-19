#!/bin/bash
# Program:
#   using the return command  in a  function
# History:
# 2019.06.18 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------创建函数-----------------------
function func1 {
    read -p "Enter a value: " value
    echo "This is an example of a function"
    echo "Doubling the value"
    return $[ $value * 2  ]
}

echo "-----------------------使用函数----------------------"
func1
#$?变量会返回执行的最后一条命令的退出状态码，范围在0~255
echo " The new value is $? "      #注意该返回值命令一定要紧接着使用函数的命令，执行其他命令后，返回值就会丢失
