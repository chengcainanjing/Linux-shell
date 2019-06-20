#!/bin/bash
# Program:
#   using a function in a script
# History:
# 2019.06.18 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------创建函数-----------------------
function func1 {
    echo "This is an example of a function"
}

echo "-----------------------使用函数----------------------"
count=1
while [ $count -le 5 ]; do
    echo  -n "Loop #$count:" ;func1
    count=$[ $count + 1 ]
done

echo "This is the end of the loop"
func1
echo "Now this is the end of the script"