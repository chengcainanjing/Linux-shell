#!/bin/bash
# Program:
#	redirecting input file descriptors
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------创建输入文件描述符----------------------"
exec 6<&0                   #文件描述符6表示保存STDIN的位置，该行表示将屏幕输入重定向到文件输入
exec 0<sh24input.file       #将STDIN输入重定向到文件中

count=1
while read line
do
    echo "Line #$count : $line"
    count=$[ count + 1 ]
done

exec 0<&6                   #恢复由文件输入，改为由屏幕输入

read -p "Are you done now?" answer
case $answer in
    y|Y)
        echo "Goodbye"
        ;;
    n|N)
        echo "Sorry, this is the end."
        ;;
    *)
        echo "Please input 'y|Y' or 'n|N'"
        ;;
esac
