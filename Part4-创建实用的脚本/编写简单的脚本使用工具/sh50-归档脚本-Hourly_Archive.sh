#!/bin/bash
# Program:
#       Hourly_Archive - Every hour create an archive
# History:
# 2019.07.15 chengcai	First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Daily_Archive - Archive designated files & directories
#######################################################
#
# Set Configuration and Destination File
#
CONFIG_FILE=/home/cc/Files_To_Backup
#
#Gather Current Data
#
DAY=`date +%y`
MONTH=`date +%m`
TIME=`date +%k0%M`
#
# Set Base Archive Destination Location
#
BASEDEST=/home/cc/backup
#
# Create Archive Destination Directory
mkdir -p $BASEDEST/$MONTH/$DAY
#
# Build Archive Destination File Name
DESTINATION=$BASEDEST/$MONTH/$DAY/cc$TIME.tar.gz
#
######## Main Script ############################
#
# Check Backup Config file exists
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
# Build the name of all the files to backup
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
# backup the files and compress archive
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