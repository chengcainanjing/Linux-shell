#!/bin/bash
# Program:
#       Daily_Archive - Archive designated files & directories
# History:
# 2019.07.15 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Daily_Archive - Archive designated files & directories
#######################################################
#
#Gather Current Data
#
DATE=$(date +%y%m%d)
#
#Set Archive File Name
#
FILE=cc_shell$DATE.tar.gz
#
#Set Configuration and Destination File
#
CONFIG_FILE=/home/cc/Files_To_Backup
DESTINATION=/home/cc/$FILE
#
######## Main Script ############################
#
#Check Backup Config file exists
#
if [ -f $CONFIG_FILE ] #make sure the config file still exists.
then					#if it exists, do nothing but continue on
	echo
else
	echo 				#if it doesn't, issue error & exit script
	echo "$CONFIG_FILE does not exist."
	echo "Backup not completed due to missing Configuration File"
	echo
	exit
fi
#
#Build the name of all the files to backup
#
FILE_ON=1               #Start on line 1 of config file.
exec < $CONFIG_FILE     #Redirect std input to name of config file.
#
read FILE_NAME          #read lst record
#
while [ $? -eq 0 ]; do
    # make sure the file or directory exists.
    if [ -f $FILE_NAME -o -d $FILE_NAME  ]; then
        #IF file exists, add its name to the lists
        FILE_LIST="$FILE_LIST $FILE_NAME"
    else
        #IF file doesn't exist, issue warning
        echo
        echo "$FILE_NAME, does not exist."
        echo "Obviously, I will not inclode it in this archive."
        echo "It is listed on line $FILE_ON of the config file."
        echo "Continuing to build archive file."
        echo
    fi
#
    FILE_ON=$[ $FILE_ON + 1 ]   #Increase line/file number by one
    read FILE_NAME              #read next record
done
################################################
#
#backup the files and compress archive
#
echo "Starting archive..."
echo
#
tar -zcf $DESTINATION $FILE_LIST 2> /dev/null
#
echo "Archive completed"
echo "Resulting archive file is: $DESTINATION"
echo
#
exit