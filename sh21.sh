#!/bin/bash
# Program:
#	在脚本中重定向输入redirecting file input
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------输入重定向----------------------"
#exec 0< sh21input.file              #exec命令允许将STDIN重定向到Linux系统上的文件中
count=1

while read line; do                 #read line 是对于输入的文档进行逐行读取
    echo  "Line #$count: $line"
    count=$[ $count + 1 ]
#done
done < sh21input.file        #此行代码可以替换exec 0< sh21input.file与done。
echo "It is finished."