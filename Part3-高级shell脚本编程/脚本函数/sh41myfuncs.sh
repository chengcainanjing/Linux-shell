#!/bin/bash
# Program:
#   my script functions
# History:
# 2019.06.20 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#---------------------------公共使用函数-----------------------
function addem() {
    echo $[ $1 + $2 ]
}

function multem() {
    echo $[ $1 * $2 ]
}

function divem() {
    if [ $2 -eq 0 ]; then
        echo -1
    else
        echo $[ $1 / $2 ]
    fi
}
