#!/bin/bash
# Program:
#   验证邮箱
# History:
# 2019.06.27 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#-----------------------正则表达式----------------------
#
gawk --re-interval '/^([a-zA-Z0-9_\.\-\+]+)@([a-zA-Z0-9_\.\+]+)\.([a-zA-Z]{2-5})/{print $0}'