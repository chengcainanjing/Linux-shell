#!/bin/bash
# Program:
#	Repeat question until user input correct answer.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

until [ "$yn" == "yes" -o "$yn" == "YES" ]      #-a 相当于并且，-0相当于或者
do
        read -p "Please input yes/YES to stop this program: " yn
done
echo "OK! you input the correct answer."