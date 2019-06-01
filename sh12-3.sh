#!/bin/bash
# Program:
#	Use function to repeat information.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function printit(){
    echo -n "Your choice is: " && echo $1|tr 'a-z' 'A-Z'               #这个$1必须要参考下面命令的执行，
                                                                       # 加上-n 可以不断航继续在同一行显示,tr是转换命令，这里面是将小写转化为大写
}

echo "This program will print your selection!"
#read -p "Input your choice:" choice         #这两行（10-11）可以替换第十二行
#case $choice in
case $1 in
	"one")
		printit  one                         #请注意，printit命令后面还有接参数
		;;
	"two")
		printit  two
		;;
	"three")
		printit  three
		;;
	*)                                       #其实相当于通配符，0~无穷多个任意字符之意
		echo "Usage $0 {one|two|three}"
		;;
esac
