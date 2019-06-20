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

#将数组中每个元素遍历一遍，赋给中间变量，中间变量在传给函数
myarray=(1 2 3 4 5)
echo "The original array is : ${myarray[*]}"
#将数组中每个元素输出，赋给arg1
arg1=`echo ${myarray[*]}`
#将数组传给函数，函数将数组各个元素相加，回传
result=`addarray $arg1`
echo "The result is $result"

#-------------------------从函数返回数组------------------------
function arraydb1r() {
    local origarry
    local newarray
    local elements
    local i
    origarry=(`echo "$@"`)
    newarray=(`echo "$@"`)
    elements=$[$# - 1 ]
    for (( i = 0; i < $elements; i++ )); do
        newarray[$i]=$[ ${origarry[$i]} * 2 ]
    done

    echo ${newarray[*]}
}

myarray=(1 2 3 4 5)
echo "The original array is : ${myarray[*]}"
arg1=`echo ${myarray[*]}`
#将数组传给函数，函数将数组各个元素乘以2，回传数组
result=(`arraydb1r $arg1`)
echo "The new array is : ${result[*]}"