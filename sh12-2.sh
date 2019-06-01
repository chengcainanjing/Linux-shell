#!/bin/bash
# Program:
#	Use function to repeat information.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function printit(){
    echo -n "Your choice is: "               #加上-n 可以不断航继续在同一行显示
}

echo "This program will print your selection!"
#read -p "Input your choice:" choice         #这两行（10-11）可以替换第十二行
#case $choice in
case $1 in
	"one")
		printit; echo $1 | tr 'a-z' 'A-Z'    #tr是转换命令，这里面是将小写转化为大写
		;;
	"two")
		printit; echo $1 | tr 'a-z' 'A-Z'    #tr是转换命令，这里面是将小写转化为大写
		;;
	"three")
		printit; echo $1 | tr 'a-z' 'A-Z'    #tr是转换命令，这里面是将小写转化为大写
		;;
	*)                                       #其实相当于通配符，0~无穷多个任意字符之意
		echo "Usage $0 {one|two|three}"
		;;
esac
