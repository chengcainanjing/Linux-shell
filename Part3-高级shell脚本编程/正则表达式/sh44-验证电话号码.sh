#!/bin/bash
# Program:
#   script to filter out bad phone numbers
# History:
# 2019.06.27 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#-----------------------正则表达式----------------------
#正则表达式，将PATH变量中的：改为空格，并赋给mypath
gawk --re-interval '/^\(?[2-9][0-9]{2}\)?(| |-|\-[0-9]{3}( |-|\.)[0-9]{4}/{pirnt $0}'