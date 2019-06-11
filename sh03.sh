#!/bin/bash
# Program:
#	test命令：1、數值比較
# History:
# 2019.06.11 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

var1=10.2       #如果是浮點數，執行會報錯：[: 10.2: integer expression expected，
var2=9
var3=33.2
var4=71

if [ $var1 -gt $var2 ]; then                            #-gt 表示大于，在test命令中不能使用浮點值
    echo "The test value $var1 is greater than $var2"
else
    echo "The test values are different"
fi
