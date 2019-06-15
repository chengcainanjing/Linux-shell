#!/bin/bash
# Program:
#   testing signal trapping
# History:
# 2019.06.15 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

trap "echo 'Sorry! I have trapped ctrl-c'" SIGINT

echo "This is a test script."
count=1
while [ $count -le 15 ]; do
    echo "LOOP $count"
    sleep 1
    count=$[ $count + 1 ]
done

echo "This is the end of the test script."