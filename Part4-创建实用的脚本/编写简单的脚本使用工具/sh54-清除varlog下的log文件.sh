#!/bin/bash
# Program:
#       清除/var/log下的log文件
# History:
# 2019.08.23 chengcai	First release
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
################### Main Script ############################
#版本一
############################################################
cd /var/log
cat /dev/null > messages
cat /dev/null > wtmp
echo "Logs cleans up."
############################################################
#
#版本二
############################################################
#如果使用变量，一定比把代码写死的好
LOG_DIR=/var/log
cd $LOG_DIR

cat /dev/null > messages
cat /dev/null > wtmp

echo "Logs cleans up."

#这个命令是一种正确并且合适的退出脚本的方法
#exit
#############################################################
#
#版本三
############################################################
#清除：一个增加的和广义的删除logfile的脚本
#
LOG_DIR=/var/log
ROOT_UTD=0                  #$UID为0的时候，用户才具有root用户的权限
LINES=50                    #默认的保存行数
E_XCD=66                    #不能修改目录
E_NOTROOT=67                #非root用户将以error退出

#使用root用户运行
if [ "$UID" -ne "$ROOT_UTD" ]
then
    echo "Must be root to run this script."
    exit $E_NOTROOT
fi

#测试是否有命令行
if [ -n "$1" ]
# 测试是否有命令行参数（非空）
then
    lines=$1
else
    lines=$LINES #默认，如果不在命令行中指定
fi

#  建议使用下边的更好的方法来检测命令行参数
#+ 但对于这章来说有点超前
#
#E_WRONGARGS=65 # 非数值参数（错误的参数格式）
#
#case "$1" in
#"") lines=50;;
#*[!0-9]*)
#    echo "Usage: basename $0 file to cleanup"
#    exit $E_NOTROOT
#    ;;
#* )
#    lines=$1
#   ;;
#esac

cd $LOG_DIR

# 检查是否在/var/log目录下
# 或者 if [ "$PWD" != "$LOG_DIR" ]
if [ `pwd` != "$LOG_DIR" ]
then
    echo "Can't change to $LOG_DIR."
    exit $E_XCD
fi

# 更有效的做法
#
# cd /var/log || {
#   echo "Can't change to necessary directory." >&2
#   exit $E_XCD ;
# }

# 保存log file 消息的最后部分。
tail -$lines messages > mesg.temp
# 变为新的log目录
mv mesg.temp messages

# cat /dev/null > messages
# 不在需要了，使用上边的方法更安全

cat /dev/null > wtmp
echo "Logs cleaned up."

# 退出之前返回0
# +返回0表示成功
#exit 0














