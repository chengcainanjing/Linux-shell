#!/bin/bash
# Program:
#	Show "Hello" from $1... by using case ... esac
# History:
# 2018.12.06 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

case $1 in
	"hello")
		echo "Hello, how are you?"
		;;
	"")
		echo "You MUST input parameters, ex> {$0 someword}"
		;;
	*)          #其实相当于通配符，0~无穷多个任意字符之意
		echo "Usage $0 {hello}"
		;;
esac
