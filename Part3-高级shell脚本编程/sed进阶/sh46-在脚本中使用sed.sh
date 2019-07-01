#!/bin/bash
# Program:
#   shell wrapper for sed editor script.
#                    to reverse text file lines.
# History:
# 2019.07.01 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#-----------------------反转文本----------------------
sed -n '{
1!G
h
$p}' $1