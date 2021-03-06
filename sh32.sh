#!/bin/bash
# Program:
#   modifying a set trap
# History:
# 2019.06.15 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------修改或移除捕获----------------------"
trap "echo 'Sorry! I have trapped ctrl-c'" SIGINT
trap "echo 'Goodbye...'" EXIT                   #捕获脚本退出


echo "This is a test script."
count=1
while [ $count -le 6 ]; do
    echo "LOOP $count"
    sleep 1
    count=$[ $count + 1 ]
done

echo "-----------------------修改捕获----------------------"
trap "echo 'I modified the trap'" SIGINT        #修改信号捕获
count=1
while [ $count -le 6 ]; do
    echo "SECOND LOOP $count"
    sleep 1
    count=$[ $count + 1 ]
done

echo "-----------------------移除捕获----------------------"
trap -- SIGINT                                  #-/-- 都可以恢复信号的默认行为
count=1
while [ $count -le 6 ]; do
    echo "THIRED LOOP $count"
    sleep 1
    count=$[ $count + 1 ]
done