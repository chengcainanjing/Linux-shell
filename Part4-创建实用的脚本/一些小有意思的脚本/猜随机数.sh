#!/bin/bash
# Program:
#       循环1-100数字.
#           1、能被3整除，输出fizz
#           2、能被5整除，输出buzz
#           3、同时被3、5整除，输出fizzbuzz
# History:
# 2019.08.10 chengcai   First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

for (( i = 1; i <= 100; ++i )); do
    #能被3整除
    b=$(($i % 3))
    #能被5整除
    c=$(($i % 5))
    #能被15整除
    d=$(($i % 15))
    #浮点数与整数比较
    if [ $(echo  "$d == 0" | bc) == 1  ]; then
        echo "fizzbuzz"
    elif [ $(echo  "$c == 0" | bc ) == 1 ] ; then
        echo "buzz"
    elif [ $(echo  "$b == 0" | bc) == 1 ] ; then
        echo "fizz"
    else
        echo $i
    fi
done

