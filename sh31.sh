#!/bin/bash
# Program:
#   trapping the script exit
# History:
# 2019.06.15 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------捕获脚本退出----------------------"
trap "echo 'Goodbye...'" EXIT

echo "This is a test script."
count=1
while [ $count -le 10 ]; do
    echo "LOOP $count"
    sleep 1
    count=$[ $count + 1 ]
done

echo "This is the end of the test script."