#!/bin/bash
# Program:
#	查询可执行文件.
# History:
# 2019.06.11 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#
IFS=:
for folder in $PATH ; do
    echo "$folder:"
    for file in $folder/* ; do
        if [ -x $file ]; then
            echo " $file"
        fi
    done
done
