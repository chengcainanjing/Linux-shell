#!/bin/bash
# Program:
#	creating  a temp file in /tmp
#   using a temporary directory
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------在/tmp中创建临时文件----------------------"
tmpfile=$(mktemp -t sh27test.XXXXXX)        #-t选项会强制系统在临时目录下新建该文件，并返回全路径。

echo "This is a test file." >$tmpfile
echo "This is the second line of the test." >>$tmpfile

echo "The temp file is located at : $tmpfile"
cat $tmpfile

rm -f $tmpfile


echo "-----------------------创建临时目录----------------------"
tempdir=$(mktemp -d sh27dir.XXXXXX)        #-d选项会强制系统在运行目录下创建临时目录，并返回目录名。
cd $tempdir

sh27tempfile1=$(mktemp sh27temp.XXXXXX)
sh27tempfile2=$(mktemp sh27temp.XXXXXX)
exec 7> $sh27tempfile1
exec 8> $sh27tempfile2

echo "Sending data to directory $tempdir"
echo "This is a test line of data for $sh27tempfile1" >&7
echo "This is a test line of data for $sh27tempfile2" >&8
