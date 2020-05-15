#!/bin/bash
# Program:
#	let user input a directory and find the whole file's permission.
# History:
# 2019.06.01 chengcai	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

for (( i = 1; i <=100; ++i )); do
    if [ "i%3|bc" -eq 0]; then
        echo "fizz"
    elif [ "i%5|bc" = 0 ] ; then
        echo "buzz"
    else
        echo $i
    fi
done

