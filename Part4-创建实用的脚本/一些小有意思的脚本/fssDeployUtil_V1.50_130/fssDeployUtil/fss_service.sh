#!/bin/bash

# Shell Script Details:
# Name:                                 fss_service.sh
# Version:                              1.1.3
# Author:                               Huangyan
# Description:                          deploy fss services 
# Date:                                 Mon Jun 19 19:11:32 CST 2017

Usage()  
{  
    echo ""
	echo "================================ERROR: wrong arguments!================================================="
    echo "====================================Deploy Explanation=================================================="
	echo " The arguments in [] are required, and the arguments in <> are optional.   "
	echo " Deploy command include as follows       :   prepare | start | stop | restart | clean , etc. "
	echo " excute sequence                         :   prepare  -> start "
	echo " ./fss_service.sh prepare [--mysqlhost=] :  prepareOnlyCloudera & prepareOnlyES [--mysqlhost=] "
	echo " ./fss_service.sh start          :   startOnlyCloudera & startOnlyES  "
	echo " ./fss_service.sh stop           :   stopOnlyCloudera & stopOnlyES  "
	echo " ./fss_service.sh restart        :   restartOnlyCloudera & restartOnlyES  "
	echo " ./fss_service.sh clean          :   cleanOnlyCloudera & cleanOnlyES  "
	echo " ./fss_service.sh prepareOnlyCloudera [--mysqlhost=] :   modifyAndUploadconfigfiles & execIndexer install & uploadjars & restarthbase & Create topics & createUDF & Create phoenix table "
	echo " ./fss_service.sh startOnlyCloudera      :   execStreaming start "
	echo " ./fss_service.sh stopOnlyCloudera       :   execStreaming stop "
	echo " ./fss_service.sh restartOnlyCloudera    :   stopOnlyCloudera & startOnlyCloudera"
	echo " ./fss_service.sh cleanOnlyCloudera      :   Delete topics and groupid & Delete tables"
	echo " ./fss_service.sh prepareOnlyES [--mysqlhost=] :   prepareOnlyCloudera & modifyAndUploadconfigfiles & execIndexer stop & esManage prepare"
    echo " ./fss_service.sh startOnlyES    :   execIndexer start & esManage remoteExecEstool "
    echo " ./fss_service.sh stopOnlyES     :   do nothing"
    echo " ./fss_service.sh restartOnlyES  :   stopOnlyES & startOnlyES "
    echo " ./fss_service.sh cleanOnlyES    :   execIndexer delete & esManage delete"
	
	echo "================================ Deploy usage ======================================================================"
	echo "================================  ./fss_service.sh [command] <args> ================================================"
	echo "================================ Tools usage 	 ==================================================================="
	echo "================================  ./fss_service.sh getVersion 		============================================"
	echo "================================  ./fss_service.sh getServerHosts 	============================================"
	echo "================================  ./fss_service.sh uploadjars 		============================================"	
	echo "================================  ./fss_service.sh uploadconfigfiles 	============================================"
	echo "================================  ./fss_service.sh uploadconfigfile [fileName] ====================================="
	echo "================================  ./fss_service.sh modifyconfigfile [fileName] [paramName] [paramValue] ============"
	echo "================================  ./fss_service.sh modifyAndUploadconfigfiles <--mysqlhost=> ======================="
	echo "================================  ./fss_service.sh createUDF 	        ============================================"
	echo "================================  ./fss_service.sh topicManage [command] <topicname partitionNum replicationNum> ==="
	echo "================================  ./fss_service.sh tableManage [command] <args>       =============================="
	echo "================================  ./fss_service.sh esManage [command] <name> ======================================="
	echo "================================  ./fss_service.sh execStreaming [command] ========================================="
	echo "================================  ./fss_service.sh execNNCompare [command] ========================================="
	echo "================================  ./fss_service.sh execIndexer [command] ==========================================="
	echo "================================  ./fss_service.sh prepareFssService     ==========================================="
	echo "================================  ./fss_service.sh cleanFssService       ==========================================="

	echo "====================================Tools Examples=================================================================="
	echo "=== ./fss_service.sh modifyconfigfiles producer.properties bootstrap.servers lv01.dct-znv.com:6667,lv03.dct-znv.com:6667 =="
	echo "=== ./fss_service.sh topicManage {create|delete} topicname:  ./fss_service.sh topicManage create topic-test ==============="
	echo "=== ./fss_service.sh tableManage {create|delete}:  ./fss_service.sh topicManage create ===================================="
	echo "=== ./fss_service.sh execStreaming {start|stop|restart} :  ./fss_service.sh execStreaming start ==========================="
	echo "=== ./fss_service.sh execNNCompare {start|stop} :  ./fss_service.sh execNNCompare start ==========================="
	
    exit 1  
}

# parameter is necessary
if [ "$1" = "" ]  
then  
    Usage  
fi 

LOCAL_PATH=`pwd`
LOCAL_JARS_DIR=$LOCAL_PATH/lib
HBASE_LOCAL_JARS_DIR=$LOCAL_JARS_DIR/hbase-local-jars
HBASE_CUSTOM_COPROCESSOR_JAR=hbase-custom-coprocessor-*.jar
PHOENIX_UDF_JAR_NAME=$LOCAL_JARS_DIR/hbase-dynamic-jars/PhoenixUDF.jar
LOCAL_CONFIG_DIR=$LOCAL_PATH/config
LOCAL_FSS_CONFIG_FILE=$LOCAL_CONFIG_DIR/fss.properties
LOCAL_LOG_DIR=$LOCAL_PATH/temp/log
DEPLOY_LOG_FILE=$LOCAL_PATH/temp/log/fssDeploy.out
LOCAL_TOOLS_DIR=$LOCAL_PATH/tools
OLD_MAN_TOOL=$LOCAL_TOOLS_DIR/oldman-alarm.sh
ES_EXCUTE_TOOL=$LOCAL_TOOLS_DIR/es-manage.sh
INDEXER_INSTALL_TOOL=$LOCAL_TOOLS_DIR/hbase-indexer-install.sh
GET_XML_VAL_TOOL=$LOCAL_TOOLS_DIR/get-xml-value.sh
SPARK_STREAMING_TOOL=$LOCAL_TOOLS_DIR/spark-realtime.sh
SPARK_NNCompare_TOOL=$LOCAL_TOOLS_DIR/spark-nnCompare.sh
ZK_CLI_TOOL_JAR=$LOCAL_TOOLS_DIR/zk-tool/ZkCliTool-1.0-SNAPSHOT.jar
CLUSTER_CONF_TEMP_FIME=$LOCAL_PATH/temp/config/cluster-conf.properties
VERSION_FILE=version.info
#for pid
FSS_PID_DIR=/var/run/fss
#for cloudera
HBASE_DYNAMIC_JARS_DIR=/hbase/lib
HBASE_ZNODE_RS_PATH=/hbase/rs
KAFKA_ZNODE_BROKER_PATH=/brokers/ids
PHOENIX_HOME=/usr/cdh/phoenix
CDH_PACKAGE_PATH=/opt/cloudera/parcels
HBASE_LIB_PATH=$CDH_PACKAGE_PATH/CDH/lib/hbase/lib
#SPARK_LIB_PATH=/opt/cloudera/parcels/SPARK2/lib/spark2/jars
SPARK_LIB_PATH=$CDH_PACKAGE_PATH/CDH/lib/spark/lib
ZK_BIN_PATH=$CDH_PACKAGE_PATH/CDH/lib/zookeeper/bin
PHOENIX_CLIENT_JAR_NAME=$SPARK_LIB_PATH/phoenix-client.jar 
KAFKA_TOPIC_TOOL=$CDH_PACKAGE_PATH/KAFKA/bin/kafka-topics
HADOOP_CONF_FILE=/etc/hadoop/conf/core-site.xml
HBASE_CONF_FILE=/etc/hbase/conf/hbase-site.xml
KAFKA_CONF_FILE=/etc/kafka/conf/kafka-client.conf
#
CDH_SERVER_IP=`awk -F= '{if($1~/^server_host$/) print $2}' /etc/cloudera-scm-agent/config.ini`
HDFS_URL=`$GET_XML_VAL_TOOL $HADOOP_CONF_FILE fs.defaultFS`
ZK_QUORUM=`$GET_XML_VAL_TOOL $HBASE_CONF_FILE hbase.zookeeper.quorum`
ZK_PORT=`awk -F= '{if($1~/^zookeeper.clientPort$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
#config dir
HDFS_FSS_DIR=`awk -F= '{if($1~/^fss.hdfs.conf.parentdir$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
HDFS_CONFIG_DIR=$HDFS_FSS_DIR/config
HDFS_FSS_URL=$HDFS_URL/$HDFS_FSS_DIR

export LOCAL_PATH
export LOCAL_JARS_DIR
export LOCAL_TOOLS_DIR
export LOCAL_LOG_DIR
export LOCAL_FSS_CONFIG_FILE
export DEPLOY_LOG_FILE
export PHOENIX_HOME
export HBASE_LIB_PATH
export SPARK_LIB_PATH
export HDFS_FSS_URL
export CDH_SERVER_IP


if [ ! -d "temp" ]; then  
sudo mkdir temp  
fi
if [ ! -d "temp/config" ]; then  
sudo mkdir temp/config  
fi
if [ ! -d "temp/log" ]; then  
sudo mkdir temp/log  
fi

if  [ "$FSS_PID_DIR" == "" ] || [ ! -d "$FSS_PID_DIR" ]; then 
sudo mkdir -p $FSS_PID_DIR
fi

################################################# Prepare ##################################################
function prepare() {
	echo " "
	if [ $# -lt 1 ]; then
		echo "Please input mysql server host!"
		echo ""
		exit 1
	fi
	echo " "
	echo "Prepare both Cloudera and ES environment!!!"
	prepareOnlyES $*
	prepareFssService
}

function prepareOnlyCloudera() {

    echo ""
	echo "Prepare Cloudera environment!!!"
	echo " "
	echo "Step 1."
	modifyAndUploadconfigfiles
	
    echo " "
	echo "Step 2."
	echo " "
	execIndexer install
	execIndexer predelete
	
	echo " "
	echo "Step 3."
	uploadjars
	
	#restart hbase cluster
	echo " "
	echo "Step 4."
	restarthbase

	sed -i 's/^Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers

	echo ""
	echo "Step 5."
	echo ""
	echo "Create topics"
	ANALYSIS_TOPIC_NAME=`awk -F= '{if($1~/^fss.kafka.topic.analysis.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ANALYSIS_PARTITION_NUM=`awk -F= '{if($1~/^fss.kafka.topic.analysis.partition.num$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ANALYSIS_REPLICATION_NUM=`awk -F= '{if($1~/^fss.kafka.topic.analysis.replication.num$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	BLACKLISTCHANGE_TOPIC_NAME=`awk -F= '{if($1~/^fss.kafka.topic.blacklistchange.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	BLACKLISTCHANGE_PARTITION_NUM=`awk -F= '{if($1~/^fss.kafka.topic.blacklistchange.partition.num$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	BLACKLISTCHANGE_REPLICATION_NUM=`awk -F= '{if($1~/^fss.kafka.topic.blacklistchange.replication.num$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ALARM_TOPIC_NAME=`awk -F= '{if($1~/^fss.kafka.topic.alarm.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ALARM_PARTITION_NUM=`awk -F= '{if($1~/^fss.kafka.topic.alarm.partition.num$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ALARM_REPLICATION_NUM=`awk -F= '{if($1~/^fss.kafka.topic.alarm.replication.num$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	topicManage create $ANALYSIS_TOPIC_NAME $ANALYSIS_PARTITION_NUM $ANALYSIS_REPLICATION_NUM 1>>$DEPLOY_LOG_FILE 2>&1
	topicManage create $BLACKLISTCHANGE_TOPIC_NAME $BLACKLISTCHANGE_PARTITION_NUM $BLACKLISTCHANGE_REPLICATION_NUM 1>>$DEPLOY_LOG_FILE 2>&1
	topicManage create $ALARM_TOPIC_NAME $ALARM_PARTITION_NUM $ALARM_REPLICATION_NUM 1>>$DEPLOY_LOG_FILE 2>&1
    echo "Create topics successfully!!!"
	
	echo ""
	echo "Step 6."

	createUDF
	
	echo ""
	echo "Step 7."
	echo ""
	echo "Create phoenix table"
	tableManage create 2>&1 1>>$DEPLOY_LOG_FILE
	echo "Create phoenix table successfully!!!"


}

function prepareOnlyES() {
    echo ""
	if [ $# -lt 1 ]; then
		echo "Please input mysql server hostname !"
		echo ""
		exit 1
	fi
	
	echo ""
	echo "Before exec prepareOnlyES, we must exec prepareOnlyCloudera first !!!"
	echo ""
	echo "Exec prepareOnlyCloudera now!!!"
	prepareOnlyCloudera $*
	
	echo ""
	echo "Prepare ES environment!!!"
	echo ""
	echo "Step 1."
	modifyAndUploadconfigfiles $*
	
	echo ""
	echo "Step 2."
	execIndexer stop
	
	echo ""
	echo "Step 3."
	esManage prepare
	echo ""
}


function restarthbase() {
    echo " "
	echo "Restart HBase now!!!"
	echo " "
    curl -u admin:admin  -X POST http://$CDH_SERVER_IP:7180/api/v16/clusters/cluster/services/hbase/commands/restart 2>&1 1>>$DEPLOY_LOG_FILE
	
    #the request finished or not
    echo "Check running request"
    #select count(1) from cm.COMMANDS where end_instant is null;
    request_num=`mysql -ucm -p123456 -e "select count(1) from cm.COMMANDS where end_instant is null;"| sed -n 2p |sed s/[[:space:]]//g`
    echo $request_num" request is running..."

    while [[ $request_num -ne 0 ]]
    do
    sleep 10
    request_num=`mysql -ucm -p123456 -e "select count(1) from cm.COMMANDS where end_instant is null;"| sed -n 2p |sed s/[[:space:]]//g`
    echo $request_num" request is running..."
    done

    echo "Request finished"	
	echo "Restart HBase successfully!!!"	
}

################################################# excute ##################################################

function start () {
	echo ""
	echo "Start program!!!" 
    echo ""
	startOnlyCloudera
	startOnlyES
}

function startOnlyCloudera () {

    echo ""
	echo "Start Cloudera program!!!"
	echo ""
	echo "Step 1."

	execStreaming start
	sleep 1

	#echo ""
	#echo "Step 2."

	#execChildanalyze start
	#sleep 1

	#echo ""
	#echo "Step 3."

	#execOldmananalyze start day
	#sleep 1
}

function startOnlyES () {
    echo ""
	echo "Start ES program!!!"
	echo ""
	echo "Step 1: exeIndexer start."
	echo ""
	execIndexer start
	echo ""
	echo "Step 2: esManage remoteExecEstool."
	echo ""
	esManage remoteExecEstool
	echo ""
}


################################################# stop ##################################################
function stop(){
	echo ""
	echo "Stop program!!!" 
    echo ""
	stopOnlyCloudera
	stopOnlyES
	echo ""
}

function stopOnlyCloudera(){
    echo ""
	echo "Stop Cloudera program!!!"
	echo ""
	echo "Step 1."
	execStreaming stop
	sleep 1

	#echo ""
	#echo "Step 2."
	#execChildanalyze stop
	#sleep 1

	#echo ""
	#echo "Step 3."
	#execOldmananalyze stop
	#sleep 1
	
}

function stopOnlyES(){
    echo ""
	echo "Stop ES program!!!"
	execIndexer stop
	echo "Stop ES program end!!!"
	echo ""
}

################################################# restart ##################################################
function restart(){
	echo ""
	echo "Restart program!!!" 
	restartOnlyCloudera
	restartOnlyES
}

function restartOnlyCloudera(){
    echo ""
	echo "Restart Cloudera program!!!"
	echo ""
	
	stopOnlyCloudera
	startOnlyCloudera
}

function restartOnlyES(){
    echo ""
	echo "Restart ES program!!!"
	
	stopOnlyES
	startOnlyES
}

################################################# clean ##################################################
function clean(){
	echo ""
	echo "Clean environment!!!"
	echo ""
	cleanFssService
	cleanOnlyCloudera
	cleanOnlyES
}

function cleanOnlyCloudera(){

    echo ""
	echo "Clean Cloudera environment!!!"
	echo ""
	
	getPassword
	echo ""	
	
	echo "Exec stopOnlyCloudera now!!!"
	stopOnlyCloudera >>$DEPLOY_LOG_FILE 2>&1
	echo ""
	echo "Step 1."
	echo ""
	echo "Delete topics and groupid:"
	echo "Please ensure web has stopped consuming topics!!!"
	BLACKLISTCHANGE_TOPIC_NAME=`awk -F= '{if($1~/^fss.kafka.topic.blacklistchange.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ANALYSIS_TOPIC_NAME=`awk -F= '{if($1~/^fss.kafka.topic.analysis.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ALARM_TOPIC_NAME=`awk -F= '{if($1~/^fss.kafka.topic.alarm.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`	
	STREAMING_GROUPID=`awk -F= '{if($1~/^fss.kafka.consumer.streaming.group.id$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	WEB_GROUPID=`awk -F= '{if($1~/^fss.kafka.consumer.web.group.id$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	topicManage delete $BLACKLISTCHANGE_TOPIC_NAME 1>>$DEPLOY_LOG_FILE 2>&1
	topicManage delete $ANALYSIS_TOPIC_NAME 1>>$DEPLOY_LOG_FILE 2>&1
	topicManage delete $ALARM_TOPIC_NAME 1>>$DEPLOY_LOG_FILE 2>&1
	cd $ZK_BIN_PATH
	./zkCli.sh -server $CDH_SERVER_IP:2181 1>>$DEPLOY_LOG_FILE 2>&1 <<EOF
	rmr /consumers/$STREAMING_GROUPID
	quit
EOF
	echo "Delete topics and groupid end!"
	
	echo ""
	echo "Step 2."
	echo ""
	echo "Delete tables:"
	tableManage delete 2>&1 1>>$DEPLOY_LOG_FILE
	echo "Delete tables end!"
}

function cleanOnlyES(){
	echo ""
	echo "Clean ES environment!!!"
	
	getPassword
	
	echo ""
	echo "Exec stopOnlyES now!!!"
	stopOnlyES >>$DEPLOY_LOG_FILE 2>&1
	echo ""
	echo "Step 1: esIndexer delete."
	echo ""
	execIndexer start >>$DEPLOY_LOG_FILE 2>&1
    execIndexer delete
    sleep 6
    execIndexer stop
    echo ""
		
	echo "Step 2: esManage delete."
	echo ""
	esManage delete >>$DEPLOY_LOG_FILE 2>&1
	echo ""
}

########################Upload single config files to hdfs##############################################
function uploadconfigfile() {
	if [ $# -ne 1 ]; then
		echo ""
		echo "Error!! File name is null!!!" 
		echo ""
		exit 1
	fi
	
	FILENAME=$1

	sudo -u hdfs hadoop fs -mkdir -p $HDFS_CONFIG_DIR
	sudo -u hdfs hadoop fs -put -f $LOCAL_CONFIG_DIR/$FILENAME $HDFS_CONFIG_DIR

	echo "Upload $FILENAME to hdfs successfully!!!" 
	[ $? -ne 0 ] && exit $?
}

########################Upload config file to hdfs##############################################
function uploadconfigfiles() {
	
	echo "Upload config files to hdfs!!!" 

	sudo -u hdfs hadoop fs -mkdir -p $HDFS_CONFIG_DIR
	sudo -u hdfs hadoop fs -put -f $LOCAL_CONFIG_DIR/*.properties $HDFS_CONFIG_DIR

	echo "Upload config files to hdfs end!!!" 
	[ $? -ne 0 ] && exit $?
}


########################modify config file params######################################
function modifyconfigfile() {
	echo ""
	echo "modify $1 : $2 = $3!!!" 
	echo ""

	if [ $# -ne 3 ]; then
	echo "Error!! Invalid params!! "
	exit 1
	fi

	rm -rf temp/config/*
	hadoop fs -get $HDFS_CONFIG_DIR/$1 temp/config
	if [ ! -f "temp/config/$1" ]; then
	cp -rf $LOCAL_CONFIG_DIR/$1 temp/config
	fi
	
	VAL_TMP=`echo "$3" | sed 's#\/#\\\/#g'`
			
	sed -i "s/^$2.*/$2=$VAL_TMP/g" temp/config/$1
	sed -i "s/^$2.*/$2=$VAL_TMP/g" $LOCAL_CONFIG_DIR/$1
	sudo -u hdfs hadoop fs -put -f temp/config/$1 $HDFS_CONFIG_DIR

	echo "modify $1 end!!! " 

	[ $? -ne 0 ] && exit $?
}

########################Modify and upload config files to hdfs##############################################
function genclusterconffile() {
	java -cp $ZK_CLI_TOOL_JAR com.znv.zookeeper.ZkCliTool $1:2181 gethbasers $HBASE_ZNODE_RS_PATH $CLUSTER_CONF_TEMP_FIME >>$DEPLOY_LOG_FILE 2>&1
	java -cp $ZK_CLI_TOOL_JAR com.znv.zookeeper.ZkCliTool $1:2181 getkafkabrokers $KAFKA_ZNODE_BROKER_PATH $CLUSTER_CONF_TEMP_FIME >>$DEPLOY_LOG_FILE 2>&1
}

function modifyAndUploadconfigfiles() {
	echo ""
	echo "Modify and upload config files to hdfs!!!" 
	
	declare eshost
	declare mysqlhost
	eshost=`hostname`
	
	for args in $*
	do	
		argname=`echo $args | cut -d "=" -f 1`
		argvalue=`echo $args | cut -d "=" -f 2`
		if [ "$argname" == "--mysqlhost" ]; then
			mysqlhost=$argvalue
		else
			echo "Invalid arguments $argname "
		fi
	done
	
	SCHEMA_NAME=`awk -F= '{if($1~/^fss.phoenix.schema.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	HISTORY_TABLENAME=`awk -F= '{if($1~/^fss.phoenix.table.history.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	ALARM_TABLENAME=`awk -F= '{if($1~/^fss.phoenix.table.alarm.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	PERSONLIB_TABLENAME=`awk -F= '{if($1~/^fss.phoenix.table.blacklist.name$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
	INDEXER_FSS_HISTORY_CONF=$LOCAL_PATH/config/es-template/fss_arbitrarysearch_history.xml
	INDEXER_FSS_ALARM_CONF=$LOCAL_PATH/config/es-template/fss_arbitrarysearch_alarm.xml
	INDEXER_FSS_PERSONLIB_CONF=$LOCAL_PATH/config/es-template/fss_person_list.xml
	#INDEXER_HEAD="<indexer table=\"$SCHEMA_NAME:$HISTORY_TABLENAME\" read-row=\"dynamic_es\" mapper=\"com.ngdata.hbaseindexer.parse.FSSAlarmResultToEsMapper\">"	
	#awk -F'"' '{if($1~/table/) $2=$HISTORY_TABLENAME}1' $INDEXER_FSS_CONFIG 1<>$INDEXER_FSS_CONFIG
	
	if [ -f "$KAFKA_CONF_FILE" ]; then
		ZK_CONNECT_TMP=`awk -F= '{if($1~/^zookeeper.connect$/) print $2}' $KAFKA_CONF_FILE`
		sed -i "s/^zookeeper.connect.*/zookeeper.connect=$ZK_CONNECT_TMP/g" $LOCAL_FSS_CONFIG_FILE
	fi
	
	genclusterconffile $ZK_QUORUM
	
	#add
	HBASE_RS_LIST=`awk -F= '{if($1~/^hbase.rs$/) print $2}' $CLUSTER_CONF_TEMP_FIME`	
	#split HBASE_RS_LIST
	OLD_IFS="$IFS"  
    IFS=","  
    rs_array=($HBASE_RS_LIST)  
    IFS="$OLD_IFS"		
	
	if [[ ${#rs_array[*]} -ge 2 ]]; then
		CAMERA_ACCESS_RANGE=`awk -F= '{if($1~/^camera.access.range$/) print $2}' $LOCAL_FSS_CONFIG_FILE`
		if [[ $CAMERA_ACCESS_RANGE == 2 ]]; then		
			modifySaltbuckets
			modifyShards
		else			
			modifyTopicPartitions2
		    modifySaltbuckets2
		    modifyShards2
		fi
	fi
	#add end
	
	KAFKA_BROKERS=`awk -F= '{if($1~/^bootstrap.servers$/) print $2}' $CLUSTER_CONF_TEMP_FIME`
	HDFS_URL_TEMP=`echo $HDFS_URL | sed 's#\/#\\\/#g'`
	
	sed -i "s/^zookeeper.quorum.*/zookeeper.quorum=$ZK_QUORUM/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^hdfs.defaultFS.*/hdfs.defaultFS=${HDFS_URL_TEMP}/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^bootstrap.servers.*/bootstrap.servers=$KAFKA_BROKERS/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^bootstrap.servers.*/bootstrap.servers=$KAFKA_BROKERS/g" $LOCAL_CONFIG_DIR/producerBasic.properties
	sed -i "s/table=\".*\"\(.read-row.*\)/table=\"$SCHEMA_NAME:$HISTORY_TABLENAME\"\1/g" $INDEXER_FSS_HISTORY_CONF
	sed -i "s/table=\".*\"\(.read-row.*\)/table=\"$SCHEMA_NAME:$ALARM_TABLENAME\"\1/g" $INDEXER_FSS_ALARM_CONF
	sed -i "s/table=\".*\"\(.read-row.*\)/table=\"$SCHEMA_NAME:$PERSONLIB_TABLENAME\"\1/g" $INDEXER_FSS_PERSONLIB_CONF
	
			
	if [ "$eshost" != "" ]; then
		sed -i "s/^es.server.ip.*/es.server.ip=http:\/\/$eshost/g" $LOCAL_FSS_CONFIG_FILE		
	fi
	
	if [ "$eshost" != "" ]; then
		es_cluster_name=`curl -s $eshost:9200 | grep 'cluster_name' | awk -F: '{print $2}' | sed 's/,//g;s/"//g;s/ //g'`
		if [[ "$es_cluster_name" != "" ]];then			
			sed -i "s/^es.cluster.name.*/es.cluster.name=$es_cluster_name/g" $LOCAL_FSS_CONFIG_FILE	
		fi			
	fi	
	
	if [ "$mysqlhost" != "" ]; then
		sed -i "s/^mysql.server.ip.*/mysql.server.ip=$mysqlhost/g" $LOCAL_FSS_CONFIG_FILE
	fi
	
	uploadconfigfiles
	echo "Modify and upload config files to hdfs successfully!!!" 

	[ $? -ne 0 ] && exit $?
}

########################Upload coprocessor jars to hbase/lib and UDF jars to hdfs#########################
function uploadjars() {
	echo ""
	echo "Upload coprocessor jars to hbase/lib and UDF jars to hdfs!!! Delete hbase/lib/phoenix-client.jar at the same time" 

	sudo -u hdfs hadoop fs -mkdir -p $HBASE_DYNAMIC_JARS_DIR
	sudo -u hdfs hadoop fs -put -f $LOCAL_JARS_DIR/hbase-dynamic-jars/*.jar $HBASE_DYNAMIC_JARS_DIR
	#read hbase rs list from zookeeper
	if [ ! -f "$CLUSTER_CONF_TEMP_FIME" ]; then 
		genclusterconffile
	fi
	HBASE_RS_LIST=`awk -F= '{if($1~/^hbase.rs$/) print $2}' $CLUSTER_CONF_TEMP_FIME`
	#split HBASE_RS_LIST
	OLD_IFS="$IFS"  
    IFS=","  
    array=($HBASE_RS_LIST)  
    IFS="$OLD_IFS"
	for rs in ${array[*]}  
    do  
		#remove old coprocessors
		ssh root@$rs "rm -rf $HBASE_LIB_PATH/$HBASE_CUSTOM_COPROCESSOR_JAR"
		#copy hbase and phoenix jars
        scp -r $HBASE_LOCAL_JARS_DIR/* root@$rs:$HBASE_LIB_PATH 
        scp -r $LOCAL_JARS_DIR/phoenix-jars/phoenix-4.9.0-cdh5.10.0-server.jar root@$rs:$PHOENIX_HOME
		scp -r $LOCAL_JARS_DIR/phoenix-jars/phoenix-4.9.0-cdh5.10.0-client.jar root@$rs:$PHOENIX_HOME
		scp -r $LOCAL_JARS_DIR/phoenix-jars/phoenix-core-4.9.0-cdh5.10.0.jar root@$rs:$PHOENIX_HOME/lib
		ssh root@$rs  "rm -rf $HBASE_LIB_PATH/phoenix-client.jar"
    done 
	
	echo "Upload jars successfully!!! "
	#echo " Please make sure that hbase.dynamic.jars.dir is configured !! "
	[ $? -ne 0 ] && exit $?
}


########################Create UDF Function##################################################
function createUDF() {
	echo ""
	echo "Create UDF Function!!!" 
	

	java -cp $PHOENIX_UDF_JAR_NAME:$PHOENIX_CLIENT_JAR_NAME com.znv.fss.phoenix.UDF.CreateFunction $HDFS_FSS_URL > temp/log/phoenix.out 2>&1 

	echo "Create UDF Function successfully!!!" 
	[ $? -ne 0 ] && exit $?
}

########################Kafka topic management##############################################
function topicManage() {

	echo ""
	
	if [ $# == 0 ]; then
		echo "Please input command: create | delete, and topic name <partitions,replication-factor>!"
		exit
	fi
	
	if [ "$1" = "create" -a $# -ne 4 ] || [ "$1" = "delete" -a $# -ne 2 ]; then
		echo "Please input command: create | delete, and topic name <partitions,replication-factor>!"
		exit
	fi
	
	if [ "$1" = "create" ]; then
		$KAFKA_TOPIC_TOOL --create --if-not-exists --partitions $3 --replication-factor $4 --topic $2 --zookeeper $ZK_QUORUM:$ZK_PORT
	elif [ "$1" = "delete" ]; then
		$KAFKA_TOPIC_TOOL --delete --if-exists --topic $2 --zookeeper $ZK_QUORUM:$ZK_PORT
		#todo delete other topics
	fi
	
	[ $? -ne 0 ] && exit $?
}

########################table management##############################################
function tableManage() {
	echo ""
	echo "$1 phoenix tables !!!" 
	echo ""
	
	if [ $# -ne 1 ]; then
		echo "Please input command: create | delete!"
		exit
	fi
	
	$LOCAL_TOOLS_DIR/table-manage.sh $1
	
	[ $? -ne 0 ] && exit $?
}

########################Submit spark streaming process task######################################
function execStreaming() {
	echo ""
	echo "$1 spark streaming process task!!!" 
	
	if [ $# -ne 1 ]; then
		echo "Please input command: start | stop | restart"
		exit
	fi
	
	$SPARK_STREAMING_TOOL $*

	echo "$1 spark streaming process task end!!!" 
	[ $? -ne 0 ] && exit $?
}
############################## Process NNCompare ############################################
function execNNCompare() {
	echo ""
	echo "$1 spark nnCompare process task!!!" 
	
	if [ $# -ne 6 ]; then
		echo "Please input command: start | stop  taskId lib1Id lib2Id threshold  port "
		exit
	fi
	
	$SPARK_NNCompare_TOOL $* 

	echo "$1 spark nnCompare process task end!!!" 
	[ $? -ne 0 ] && exit $?
}
########################Submit old man process task######################################
function execOldmananalyze() {
	echo ""
	echo "$1 old man process task!!!" 
     
	$OLD_MAN_TOOL $* 

	echo "$1 spark old man process task end!!!" 
	[ $? -ne 0 ] && exit $?
}

########################Submit child process task######################################
function execChildanalyze() {
	echo ""
	echo "$1 child process task!!!" 
	
	if [ $# -ne 1 ]; then
		echo "Please input command: start | stop | restart"
		exit
	fi
	
	CHILD_PID=$FSS_PID_DIR/childprocess.pid
	
	#kill process
	if [ "$1" = "stop" -o "$1" = "restart" ] && [ -f $CHILD_PID ]; then	
		#$LOCAL_TOOLS_DIR/kill-process.sh ChildAnalyzeMain
		echo "kill pid `cat ${CHILD_PID}` ... "
		kill -9 `cat ${CHILD_PID}` > /dev/null 2>&1
		rm -f ${CHILD_PID} > /dev/null 2>&1
	fi
	
	if [ "$1" = "start" ] && [ -f $CHILD_PID ]; then	
		echo "ERROR!! file $FSS_PID_DIR/childprocess.pid is exsit! Please stop the program and retry !"
		echo " "
		exit 1
	fi
	
	#submit process	
	if [ "$1" = "start" -o "$1" = "restart" ]; then
		# Add libs to CLASSPATH
		CLASSPATH=$HBASE_CHILD_JAR_NAME
		CLASSPATH=${CLASSPATH}:$PHOENIX_CLIENT_JAR_NAME
		CLASSPATH=${CLASSPATH}:$CDH_PACKAGE_PATH/CDH/lib/hadoop/hadoop-common.jar:$CDH_PACKAGE_PATH/CDH/lib/hadoop/hadoop-auth.jar
		CLASSPATH=${CLASSPATH}:$CDH_PACKAGE_PATH/CDH/lib/hadoop-hdfs/hadoop-hdfs.jar
		for f in $HBASE_LIB_PATH/*.jar; do
		#for f in $PHOENIX_HOME/lib/*.jar; do
		  CLASSPATH=${CLASSPATH}:$f;
		done
		export CLASSPATH

		nohup java com.znv.hbase.singleChildAnalyze.ChildAnalyzeMain $HDFS_FSS_URL > $LOCAL_LOG_DIR/childAnalyze.out 2>&1 &
		child_pid=$!
		echo $child_pid > ${CHILD_PID}
		#wait $child_pid
	fi
	
	echo "$1 child process task end!!!" 
	[ $? -ne 0 ] && exit $?
}

########################excute es templates######################################
function esManage() {
	$ES_EXCUTE_TOOL $*

	[ $? -ne 0 ] && exit $?
}

########################install hbase indexer######################################
function execIndexer() {
	echo $*
	$INDEXER_INSTALL_TOOL $*
     
	[ $? -ne 0 ] && exit $?
}

########################configure fss service#####################################
function prepareFssService(){
    echo ""
    echo "configure fss service, start on boot"

	SRC_PATH=/home/fss_v130/fssDeployUtil
    sed -i "s:$SRC_PATH:$LOCAL_PATH:g" ./tools/fssservice
	cp ./tools/fssservice /etc/init.d
    cd /etc/init.d
    chmod +x fssservice
    chkconfig --add fssservice
    chkconfig fssservice on

    [ $? -ne 0 ] && exit $?
}

########################remove the configure file of fss service#####################################
function cleanFssService(){
    echo "stop the fssservice"
	
	getPassword
	echo ""
	
    service fssservice stop
    echo "remove the configure file of fss service"
    chkconfig --del fssservice
    rm -rf /etc/init.d/fssservice

    [ $? -ne 0 ] && exit $?
}

########################get fss deploy util version ################################
function getVersion() {
	cat $VERSION_FILE | grep version
}

########################get password ################################
function getPassword() {
	echo ""
	read -s -p "please enter password: " password
	if [[ $password != $"zxm10@@@" ]]; then
		echo $'\nPermission denied!!!\n'
		exit 1
	fi
	echo ""
}


#######################modify phoenix saltbuckets camera size 300###################
function modifySaltbuckets() {
	sed -i "s/^fss.phoenix.table.blacklist.saltbuckets.*/fss.phoenix.table.blacklist.saltbuckets=48/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^fss.phoenix.table.bigpic.saltbuckets.*/fss.phoenix.table.bigpic.saltbuckets=126/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^fss.phoenix.table.history.saltbuckets.*/fss.phoenix.table.history.saltbuckets=72/g" $LOCAL_FSS_CONFIG_FILE
}

#######################modify es shards camera size 300#############################
function modifyShards() {
	sed -i "s/^fss.es.index.history.shards.*/fss.es.index.history.shards=5/g" $LOCAL_FSS_CONFIG_FILE
	#sed -i "s/^fss.es.index.alarm.shards.*/fss.es.index.alarm.shards=3/g" $LOCAL_FSS_CONFIG_FILE
	#sed -i "s/^fss.es.index.person.list.shards.*/fss.es.index.person.list.shards=15/g" $LOCAL_FSS_CONFIG_FILE
	sed -i 's/"number_of_shards".*:[^,]*/"number_of_shards": 5/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_history.json
	sed -i 's/"number_of_replicas":[^,]*/"number_of_replicas": 1/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_history.json
	sed -i 's/"number_of_shards":[^,]*/"number_of_shards": 3/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_alarm.json
	sed -i 's/"number_of_replicas":[^,]*/"number_of_replicas": 1/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_alarm.json
	sed -i 's/"number_of_shards":[^,]*/"number_of_shards": 15/g' $LOCAL_CONFIG_DIR/es-template/template_fss_person_list.json
	sed -i 's/"number_of_replicas":[^,]*/"number_of_replicas": 1/g' $LOCAL_CONFIG_DIR/es-template/template_fss_person_list.json
}

#######################modify topic partitions camera size 1000###################
function modifyTopicPartitions2() {
	sed -i "s/^fss.kafka.topic.analysis.partition.num.*/fss.kafka.topic.analysis.partition.num=30/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^fss.kafka.topic.alarm.partition.num.*/fss.kafka.topic.alarm.partition.num=30/g" $LOCAL_FSS_CONFIG_FILE
}

#######################modify phoenix saltbuckets camera size 1000###################
function modifySaltbuckets2() {
	sed -i "s/^fss.phoenix.table.blacklist.saltbuckets.*/fss.phoenix.table.blacklist.saltbuckets=48/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^fss.phoenix.table.bigpic.saltbuckets.*/fss.phoenix.table.bigpic.saltbuckets=256/g" $LOCAL_FSS_CONFIG_FILE
	sed -i "s/^fss.phoenix.table.history.saltbuckets.*/fss.phoenix.table.history.saltbuckets=150/g" $LOCAL_FSS_CONFIG_FILE
}

#######################modify es shards camera size 1000#############################
function modifyShards2() {
	sed -i "s/^fss.es.index.history.shards.*/fss.es.index.history.shards=9/g" $LOCAL_FSS_CONFIG_FILE
	#sed -i "s/^fss.es.index.alarm.shards.*/fss.es.index.alarm.shards=3/g" $LOCAL_FSS_CONFIG_FILE
	#sed -i "s/^fss.es.index.person.list.shards.*/fss.es.index.person.list.shards=15/g" $LOCAL_FSS_CONFIG_FILE
	sed -i 's/"number_of_shards".*:[^,]*/"number_of_shards": 9/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_history.json
	sed -i 's/"number_of_replicas":[^,]*/"number_of_replicas": 1/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_history.json
	sed -i 's/"number_of_shards":[^,]*/"number_of_shards": 6/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_alarm.json
	sed -i 's/"number_of_replicas":[^,]*/"number_of_replicas": 1/g' $LOCAL_CONFIG_DIR/es-template/template_fss_arbitrarysearch_alarm.json
	sed -i 's/"number_of_shards":[^,]*/"number_of_shards": 15/g' $LOCAL_CONFIG_DIR/es-template/template_fss_person_list.json
	sed -i 's/"number_of_replicas":[^,]*/"number_of_replicas": 1/g' $LOCAL_CONFIG_DIR/es-template/template_fss_person_list.json
}

########################get bigdata hosts ################################
function getServerHosts() {
	# resolve "jq" command for parse json
	if [[ ! `which jq` ]]; then
		echo "jq is not installed on target system, please install it first! "
		# adaptive for CentOS or Ubuntu
		cp -rf $LOCAL_TOOLS_DIR/jq-linux64/jq /usr/bin/
		[ $? -ne 0 ] && echo "Trying install jq failed! ";echo "Trying install jq successfully! "
		echo "$(which jq) is found!"
		echo 1
	fi

	echo ""
	echo "Cloudera Server:"
	echo $CDH_SERVER_IP
	echo ""
	
	echo "big data server hosts:"	
	server_status=`service cloudera-scm-server status|grep "is running"`
	if [[ "$server_status" != "" ]]
	then
		cluster_info=`curl -s -u admin:admin  -X GET http://$CDH_SERVER_IP:7180/api/v16/hosts`
		cluster_hosts=`echo $cluster_info | jq '.items'`
		length=`echo $cluster_info | jq '.items|length'`
		if [[ $length = "" ]]; then
			length=0
		fi
		for((i=0;i<$length;i++))
		do	
			hostIp=`echo $cluster_hosts | jq ".[$i].ipAddress" | sed 's/"//g'`
			hostName=`echo $cluster_hosts | jq ".[$i].hostname" | sed 's/"//g'`
			echo "$hostIp  $hostName"
		done
	else
		echo ""
		echo $'\nCloudera Server is not running!!!\n'
    fi
	
	echo ""
}


COMMAND=$1

#参数位置左移1
shift

case $COMMAND in
    prepare )
        prepare $*
        ;;
    start )
        start $*
        ;;
	stop )
        stop $*
        ;;
	restart )
        restart $*
        ;;
	clean )
		clean $*
		;;
	prepareOnlyCloudera )
		prepareOnlyCloudera $*
		;;
	startOnlyCloudera )
		startOnlyCloudera $*
		;;
	stopOnlyCloudera )
		stopOnlyCloudera $*
		;;
	restartOnlyCloudera )
		restartOnlyCloudera $*
		;;
	cleanOnlyCloudera )
		cleanOnlyCloudera $*
		;;
	prepareOnlyES )
		prepareOnlyES $*
		;;
	startOnlyES )
		startOnlyES $*
		;;
	stopOnlyES )
		stopOnlyES $*
		;;
	restartOnlyES )
		restartOnlyES $*
		;;
	cleanOnlyES )
		cleanOnlyES $*
		;;
    uploadjars )
        uploadjars
        ;;
    createUDF )
        createUDF
        ;;
    uploadconfigfiles )
        uploadconfigfiles
        ;;
    uploadconfigfile )
        uploadconfigfile $*
        ;;
	modifyAndUploadconfigfiles )
        modifyAndUploadconfigfiles $*
        ;;
	modifyconfigfile )
        modifyconfigfile $*
        ;;
	execStreaming )
        execStreaming $*
        ;;		
	execNNCompare )
        execNNCompare $*
        ;;		
	execChildanalyze )
        execChildanalyze $*
        ;;		
	execOldmananalyze )
        execOldmananalyze $*
        ;;
	esManage )
        esManage $*
        ;;
	execIndexer )
        execIndexer $*
        ;;	
    topicManage )
		topicManage $*
		;;
	tableManage )
		tableManage $*
		;;
	prepareFssService )
	    prepareFssService
	    ;;
	cleanFssService )
	    cleanFssService
	    ;;
	getServerHosts )
	    getServerHosts
	    ;;
	getVersion )
		getVersion
		;;
    * )
		Usage
        exit 1
        ;;
esac
