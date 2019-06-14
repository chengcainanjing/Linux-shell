#!/bin/bash
# Program:
#	testing closing file descriptors
# History:
# 2019.06.12 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "-----------------------关闭文件描述符----------------------"
exec 3> sh26.outfile

echo "This is a test line of data" >&3

exec 3>&-                   #手动关闭文件描述符，不能再脚本中向他写入任何数据，否则shell会生成错误消息

cat sh26.outfile            #还要注意的是，如果随后你在脚本中打开同一个输出文件，Shell会用一个新的脚本文件来替代已有的文件。
                            #这意味着如果在向文件中输入数据，他就会覆盖已有的文件。
exec 3> sh26.outfile
echo "This'll be bad " >&3  #在执行完此命令后，文件sh26.outfile中仅有此行输入，之前的都被覆盖。
