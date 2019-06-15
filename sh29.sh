#!/bin/bash
# Program:
#   实例运用
#   read file and create INSERT statements for MYSQL
# History:
# 2019.06.15 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------实例运用----------------------"
outfile='sh29members.sql'
IFS=','
while read lname fname address city state zip; do
    cat >> $outfile <<EOF                   #出现两处重定向符，输入重定向与输出重定向
    INSERT INTO members(lname,fname,address,city,state,zip) VALUES
    ('$lname','$fname','$address','$city','$state','$zip');
EOF
done < ${1}                                 #重定向符
