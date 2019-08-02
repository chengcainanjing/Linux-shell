#!/bin/bash
# Program:
#       Big_Users - find big disk space users in various directories
# History:
# 2019.08.02 chengcai	First release
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#
#######################################
#
# Parameters for script
#
CHECK_DIRECTORIES="/var/log /home" # directories to check
#
################### Main Script ############################
#
DATE=$(date '+%m%d%y')              #Date for report file
#
exec > disk_space_$DATE.rpt         #make report file Std Output
#
echo "Top Ten Disk Space Usage"     #report headers for while report
echo "for $CHECK_DIRECTORIES Directories"
#
for DIR_CHECK in $CHECK_DIRECTORIES ; do    #loop to du directories
    echo ""
    echo "The $DIR_CHECK Directory:"        #Title header for each directory
#
#   Creating a listing of top ten disk space users
    du -Sh $DIR_CHECK    2>/dev/null |
    sort -rn |
    sed '{11,$D; =}' |                      # =号打印行号 D：删除多行组中的一行
    #用N命令将下一行合并到那行，然后用替换命令s将换行符替换成空格。
    sed 'N; s/\n/ /' |                      # N：将数据流中的下一行加进来创建一个多行组来处理
    gawk '{printf $1 ":" "\t" $2 "\t" $3 "\n"}'
#
done                                        #end of for loop du directories
#