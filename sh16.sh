#!/bin/bash
# Program:
#	let user input a directory and find the whole file's permission.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#1. 先看看这目录是否存在啊？
read -p "Please input a directory: " dir

if [ "$dir" == "" ] || [  ! -d "$dir" ]; then
        echo "The $dir is NOT exist in your system."
        exit 1
fi

#2. 开始测试档案萝~
filelist=`ls ${dir}`                                                #`command` 倒引号 (backticks)
for filename in $filelist
do
        perm=""
        test -r "${dir}/${filename}" && perm="$perm readable"      #侦测文档名是否具有可读属性
        test -w "${dir}/${filename}" && perm="$perm writable"       #侦测文档名是否具有可写属性
        test -x "${dir}/${filename}" && perm="$perm executable"     #侦测文档名是否具有可执行属性
        echo "The file ${dir}/${filename}'s permission is ${perm}"
done










