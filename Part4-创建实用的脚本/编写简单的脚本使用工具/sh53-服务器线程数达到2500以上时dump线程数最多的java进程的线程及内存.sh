#!/bin/bash
# Program:
#       服务器线程数达到2500以上时dump线程数最多的java进程的线程及内存
# History:
# 2019.08.05 chengcai	First release
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
################### Main Script ############################
#
source ~/.bashrc
cur_thread_num=`ps -efL | wc -l`
if [ $cur_thread_num -le 2500 ]; then
    exit 0
fi

cur_date=`date +"%Y-%m-%d_%H-%M-%S"`
cd /var/log
# 服务器当前线程dump到文件：按照线程数由大到小排序显示
ps -efL --sort -nlwp > server_thread_dump_$cur_date
# dump线程数最多的jvm的线程及内存
most_thread_num_pid=`cat server_thread_dump_$cur_date |sed -n '2p' | awk '{print $2}'`
nohup jstack -l $most_thread_num_pid > java_app_thread_dump_${cur_date}_pid_${most_thread_num_pid} &
nohup jmap -dump:format=b,file=java_app_mem_dump_${cur_date}_pid_${most_thread_num_pid} $most_thread_num_pid &

exit 0