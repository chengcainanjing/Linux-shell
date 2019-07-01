#!/bin/bash
# Program:
#   count number of files in your PATH
# History:
# 2019.06.27 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#-----------------------正则表达式----------------------
#正则表达式，将PATH变量中的：改为空格，并赋给mypath
mypath=`echo $PATH | sed 's/:/ /g'`
count=0

#外层循环，将所有路径，单独赋给一个变量
for directory in $mypath ; do
    check=`ls $directory`
    echo $check
    #内层循环，将一个路径下的所有文件，单独赋给一个变量，统计文件数
    for item in $check ; do
        count=$[ $count + 1 ]
    done
    #内层循环结束后，输出目录和文件数
    echo "$directory - $count"
    count=0
done
