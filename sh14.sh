#!/bin/bash
# Program:
#	Use loop to calculate "1+2+3+...+100" result.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

i=0
s=0
while [ "$i" != "100" ]      #-a 相当于并且，-0相当于或者
do
        i=$(($i+1))
        s=$(($s+$i))
done
echo "The result of '1+2+3+...+100' is ==> $s"

#练习题，用户自行输入一个数字，让程序从1+2+3+。。。+直到你输入的数字为止.
read  -p "Please input the num you want to calculate: " num
i=0
s=0
while [ "$i" != "$num" ]      #-a 相当于并且，-0相当于或者
do
        i=$(($i+1))
        s=$(($s+$i))
done
echo "The result of '1+2+3+...+$num' is ==> $s"









