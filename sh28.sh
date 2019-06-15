#!/bin/bash
# Program:
#	记录消息
#   using the tee command for logging
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------记录消息----------------------"
tmpfile=test28.file


echo "This is a test file." | tee $tmpfile                      #tee命令，同时将命令发往两处，一处是STDOUT，一处是tee命令所指定的文件名
echo "This is the second line of the test." | tee -a $tmpfile   #-a 将数据追加到文件中
echo "This is the end of the test." | tee -a $tmpfile

cat test28.file
