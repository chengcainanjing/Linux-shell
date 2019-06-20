#!/bin/bash
# Program:
#   passing parameters to a funciton
# History:
# 2019.06.18 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------创建函数-----------------------
function addem {
    if [ $# -eq 0 ] || [ $# -gt 2 ]
    then
        echo -1
    elif [ $# -eq 1 ]
    then
        echo $[ $1 + $1 ]
    else
        echo $[ $1 + $2 ]
    fi
}

#--------------------------使用常数传参-------------------
echo -n "Adding 10 and 15:"
value=`addem 10 15`
echo $value



echo -n "Let's try adding just one number:"
value=`addem 10`
echo $value

echo -n "Now trying no numbers:"
value=`addem`
echo $value

echo -n "Finally, try adding three numbers:"
value=`addem 10 20 30`
echo $value

#-----------------------使用命令行参数传参----------------
if [ $# -eq 2 ]; then
    value=`addem $1 $2`
    echo "The value is $value"
else
    echo "Usage : badtest1 a b"
fi
