#!/bin/bash
# Program:
#       add commas to number in factorial answer.
# History:
# 2019.07.01 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#-----------------------重定向sed的输出----------------------
factorial=1
counter=1
number=$1

#阶乘
while [ $counter -le $number ]
do
    factorial=$[ $factorial * $counter ]
    counter=$[ $counter + 1 ]
done

#给结果加入逗号
result=(`echo $factorial | sed '{
:start
s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/
t start
}'`)

echo "The result is $result"