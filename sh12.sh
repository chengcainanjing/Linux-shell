#!/bin/bash
# Program:
#	This script only accepts the flowing parameter: one ,two or three.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "This program will print your selection!"
read -p "Input your choice:" choice         #这两行（10-11）可以替换第十二行
case $choice in
#case $1 in
	"one")
		echo "Your choice is ONE."
		;;
	"two")
		echo "Your choice is TWO."
		;;
	"three")
		echo "Your choice is THREE."
		;;
	*)          #其实相当于通配符，0~无穷多个任意字符之意
		echo "Usage $0 {one|two|three}"
		;;
esac
