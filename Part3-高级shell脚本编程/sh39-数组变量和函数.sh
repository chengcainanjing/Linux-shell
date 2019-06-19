#!/bin/bash
# Program:
#   adding value in the array
# History:
# 2019.06.18 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------向函数传递数组数据-----------------------
function addarray {
    local sum=0
    local newarray
#"$@" 会将各个参数分开，以"$1" "$2" … "$n" 的形式输出所有参数
#以每个单独参数传给数组
    newarray=(`echo "$@"`)
    for value in ${newarray[*]} ; do
        sum=$[ $sum + $value ]
    done
    echo $sum
}

myarray=(1 2 3 4 5)
echo "The original array is : ${myarray[*]}"
arg1=`echo ${myarray[*]}`
result=`addarray $arg1`
echo "The result is $result"
