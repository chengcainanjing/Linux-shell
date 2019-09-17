#!/bin/bash

# Shell Script Details:
# Name:                                 fss_check.sh
# Version:                              1.1.0
# Author:                               Xuzhao
# Description:                          check fss services
# Date:                                 Mon Jan 08 10:00:00 CST 2018

#Global Parameters
config_file=./config/fss.properties
error_num=0
ES_HOST=$2
#地址
#-F选项指定以逗号作为输入字段分割符
zookeeper_quorum=`awk -F= '{if($1~/^zookeeper.quorum$/) print $2}' $config_file`
zookeeper_clientport=`awk -F= '{if($1~/^zookeeper.clientPort$/) print $2}' $config_file`
hbase_znode=`awk -F= '{if($1~/^hbase.zookeeper.znode.parent$/) print $2}' $config_file`
es_server_ip=`awk -F= '{if($1~/^es.server.ip$/) print $2}' $config_file`
es_server_ip=${es_server_ip#*http://}
es_http_port=`awk -F= '{if($1~/^es.http.port$/) print $2}' $config_file`
CDH_SERVER_IP=`awk -F= '{if($1~/^server_host$/) print $2}' /etc/cloudera-scm-agent/config.ini`
#表格
schema_name=`awk -F= '{if($1~/^fss.phoenix.schema.name$/) print $2}' $config_file`
#task_tableName=`awk -F= '{if($1~/^fss.phoenix.table.task.name$/) print $2}' $config_file` (Not Used)
#cameralib_tableName=`awk -F= '{if($1~/^fss.phoenix.table.cameralib.name$/) print $2}' $config_file`
blacklist_tableName=`awk -F= '{if($1~/^fss.phoenix.table.blacklist.name$/) print $2}' $config_file`
#relationship_tableName=`awk -F= '{if($1~/^fss.phoenix.table.relationship.name$/) print $2}' $config_file`
#libconfig_tableName=`awk -F= '{if($1~/^fss.phoenix.table.libconfig.name$/) print $2}' $config_file`
bigpic_tableName=`awk -F= '{if($1~/^fss.phoenix.table.bigpic.name$/) print $2}' $config_file`
history_tableName=`awk -F= '{if($1~/^fss.phoenix.table.history.name$/) print $2}' $config_file`
alarm_tableName=`awk -F= '{if($1~/^fss.phoenix.table.alarm.name$/) print $2}' $config_file`
#oldman_tableName=`awk -F= '{if($1~/^fss.phoenix.table.oldman.temp$/) print $2}' $config_file` (Not Used)
application_name=RealtimeProcessSmartCommunity_$schema_name
topic_analysis_name=`awk -F= '{if($1~/^fss.kafka.topic.analysis.name$/) print $2}' $config_file`
topic_blacklistchange_name=`awk -F= '{if($1~/^fss.kafka.topic.blacklistchange.name$/) print $2}' $config_file`
topic_alarm_name=`awk -F= '{if($1~/^fss.kafka.topic.alarm.name$/) print $2}' $config_file`
es_history_prefix=`awk -F= '{if($1~/^fss.es.index.history.prefix$/) print $2}' $config_file`
es_search_history=`awk -F= '{if($1~/^fss.es.search.history.alias$/) print $2}' $config_file`
es_index_alarm=`awk -F= '{if($1~/^fss.es.index.alarm.name$/) print $2}' $config_file`
es_index_person_list=`awk -F= '{if($1~/^fss.es.index.person.list.name$/) print $2}' $config_file`
#获取ES的36个索引名称
index_num=0
#-le小于等于
while [ $index_num -le 35 ]
do
        #36分片
        es_index_array[$index_num]=$es_history_prefix-$index_num
        index_num=$(( $index_num+ 1 ))
done

#hbaseInfo
function hbaseInfo()
{
    #传递给脚本或函数的所有参数，将命令行上提供的所有参数当做一个单词保存
    cloudera_res=$*

    #HBASE_MASTER_HEALTH
    master_health=${cloudera_res#*\"HBASE_MASTER_HEALTH\"}
    master_health_info=${master_health#*\"summary\"}
    master_health_status=${master_health_info#*\"}
    master_health_status=${master_health_status%%\"*}
    if [[ $master_health_status == "GOOD" ]];then
        echo "HBASE_MASTER_HEALTH : Good !"
    else
        echo "HBASE_MASTER_HEALTH : Fail !"
        let error_num++
    fi

    #HBASE_REGION_SERVERS_HEALTHY
    region_servers_healthy=${cloudera_res#*\"HBASE_REGION_SERVERS_HEALTHY\"}
    region_servers_healthy_info=${region_servers_healthy#*\"summary\"}
    region_servers_healthy_status=${region_servers_healthy_info#*\"}
    region_servers_healthy_status=${region_servers_healthy_status%%\"*}
    if [[ $region_servers_healthy_status == "GOOD" ]];then
        echo "HBASE_REGION_SERVERS_HEALTHY : Good !"
    else
        echo "HBASE_REGION_SERVERS_HEALTHY : Fail !"
        let error_num++
    fi
}

#hbaseCheck
function hbaseCheck()
{
    cloudera_res=$*

    if [[ $cloudera_res =~ "HBASE" ]];then
        hbase_total=${cloudera_res#*\"HBASE\"}
        hbase_info=${hbase_total#*\"entityStatus\"}
        hbase_status=${hbase_info#*\"}
        hbase_status=${hbase_status%%\"*}
        if [[ $hbase_status == "GOOD_HEALTH" ]];then
            echo "HBase : Good !"
        else
            hbaseInfo $cloudera_res
        fi
    else
        hbaseInfo $cloudera_res
    fi
}

#zookeeperInfo
function zookeeperInfo()
{
    cloudera_res=$*

    #ZOOKEEPER_CANARY_HEALTH
    zookeeper_canary_health=${cloudera_res#*\"ZOOKEEPER_CANARY_HEALTH\"}
    zookeeper_canary_health_info=${zookeeper_canary_health#*\"summary\"}
    zookeeper_canary_health_status=${zookeeper_canary_health_info#*\"}
    zookeeper_canary_health_status=${zookeeper_canary_health_status%%\"*}
    if [[ $zookeeper_canary_health_status == "GOOD" ]];then
        echo "ZOOKEEPER_CANARY_HEALTH : Good !"
    else
        echo "ZOOKEEPER_CANARY_HEALTH : Fail !"
        let error_num++
    fi

    #ZOOKEEPER_SERVERS_HEALTHY
    zookeeper_servers_healthy=${cloudera_res#*\"ZOOKEEPER_SERVERS_HEALTHY\"}
    zookeeper_servers_healthy_info=${zookeeper_servers_healthy#*\"summary\"}
    zookeeper_servers_healthy_status=${zookeeper_servers_healthy_info#*\"}
    zookeeper_servers_healthy_status=${zookeeper_servers_healthy_status%%\"*}
    if [[ $zookeeper_servers_healthy_status == "GOOD" ]];then
        echo "ZOOKEEPER_SERVERS_HEALTHY : Good !"
    else
        echo "ZOOKEEPER_SERVERS_HEALTHY : Fail !"
        let error_num++
    fi
}

#zookeeperCheck
function zookeeperCheck()
{
    cloudera_res=$*

    if [[ $cloudera_res =~ "ZOOKEEPER" ]];then
        zookeeper_total=${cloudera_res#*\"ZOOKEEPER\"}
        zookeeper_info=${zookeeper_total#*\"entityStatus\"}
        zookeeper_status=${zookeeper_info#*\"}
        zookeeper_status=${zookeeper_status%%\"*}
        if [[ $zookeeper_status == "GOOD_HEALTH" ]];then
            echo "ZooKeeper : Good !"
        else
            zookeeperInfo $cloudera_res
        fi
    else
        zookeeperInfo $cloudera_res
    fi
}

#oozieInfo
function oozieInfo()
{
    cloudera_res=$*

    #OOZIE_OOZIE_SERVERS_HEALTHY
    oozie_servers_healthy=${cloudera_res#*\"OOZIE_OOZIE_SERVERS_HEALTHY\"}
    oozie_servers_healthy_info=${oozie_servers_healthy#*\"summary\"}
    oozie_servers_healthy_status=${oozie_servers_healthy_info#*\"}
    oozie_servers_healthy_status=${oozie_servers_healthy_status%%\"*}
    if [[ $oozie_servers_healthy_status == "GOOD" ]];then
        echo "OOZIE_OOZIE_SERVERS_HEALTHY : Good !"
    else
        echo "OOZIE_OOZIE_SERVERS_HEALTHY : Fail !"
        let error_num++
    fi
}

#oozieCheck
function oozieCheck()
{
    cloudera_res=$*

    if [[ $cloudera_res =~ "OOZIE" ]];then
        oozie_total=${cloudera_res#*\"OOZIE\"}
        oozie_info=${oozie_total#*\"entityStatus\"}
        oozie_status=${oozie_info#*\"}
        oozie_status=${oozie_status%%\"*}
        if [[ $oozie_status == "GOOD_HEALTH" ]];then
            echo "Oozie : Good !"
        else
            oozieInfo $cloudera_res
        fi
    else
        oozieInfo $cloudera_res
    fi
}

#yarnInfo
function yarnInfo()
{
    cloudera_res=$*

    #YARN_JOBHISTORY_HEALTH
    jobhistory_health=${cloudera_res#*\"YARN_JOBHISTORY_HEALTH\"}
    jobhistory_health_info=${jobhistory_health#*\"summary\"}
    jobhistory_health_status=${jobhistory_health_info#*\"}
    jobhistory_health_status=${jobhistory_health_status%%\"*}
    if [[ $jobhistory_health_status == "GOOD" ]];then
        echo "YARN_JOBHISTORY_HEALTH : Good !"
    else
        echo "YARN_JOBHISTORY_HEALTH : Fail !"
        let error_num++
    fi

    #YARN_NODE_MANAGERS_HEALTHY
    node_managers_healthy=${cloudera_res#*\"YARN_NODE_MANAGERS_HEALTHY\"}
    node_managers_healthy_info=${node_managers_healthy#*\"summary\"}
    node_managers_healthy_status=${node_managers_healthy_info#*\"}
    node_managers_healthy_status=${node_managers_healthy_status%%\"*}
    if [[ $node_managers_healthy_status == "GOOD" ]];then
        echo "YARN_NODE_MANAGERS_HEALTHY : Good !"
    else
        echo "YARN_NODE_MANAGERS_HEALTHY : Fail !"
        let error_num++
    fi

    #YARN_RESOURCEMANAGERS_HEALTH
    resourcemangers_health=${cloudera_res#*\"YARN_RESOURCEMANAGERS_HEALTH\"}
    resourcemangers_health_info=${resourcemangers_health#*\"summary\"}
    resourcemangers_health_status=${resourcemangers_health_info#*\"}
    resourcemangers_health_status=${resourcemangers_health_status%%\"*}
    if [[ $resourcemangers_health_status == "GOOD" ]];then
        echo "YARN_RESOURCEMANAGERS_HEALTH : Good !"
    else
        echo "YARN_RESOURCEMANAGERS_HEALTH : Fail !"
        let error_num++
    fi

    #YARN_USAGE_AGGREGATION_HEALTH (Not Used)
    #usage_aggregation_health=${cloudera_res#*\"YARN_USAGE_AGGREGATION_HEALTH\"}
    #usage_aggregation_health_info=${usage_aggregation_health#*\"summary\"}
    #usage_aggregation_health_status=${usage_aggregation_health_info#*\"}
    #usage_aggregation_health_status=${usage_aggregation_health_status%%\"*}
    #if [[ $usage_aggregation_health_status == "GOOD" ]];then
        #echo "YARN_USAGE_AGGREGATION_HEALTH : Good !"
    #else
        #echo "YARN_USAGE_AGGREGATION_HEALTH : Fail !"
        #let error_num++
    #fi
}

#yarnCheck
function yarnCheck()
{
    cloudera_res=$*

    if [[ $cloudera_res =~ "YARN" ]];then
        yarn_total=${cloudera_res#*\"YARN\"}
        yarn_info=${yarn_total#*\"entityStatus\"}
        yarn_status=${yarn_info#*\"}
        yarn_status=${yarn_status%%\"*}
        if [[ $yarn_status == "GOOD_HEALTH" ]];then
            echo "Yarn : Good !"
        else
            yarnInfo $cloudera_res
        fi
    else
        yarnInfo $cloudera_res
    fi
}

#sparkOnYarnInfo
function sparkOnYarnInfo()
{
    cloudera_res=$*

    #SPARK_ON_YARN
    spark_on_yarn_total=${cloudera_res#*\"SPARK_ON_YARN\"}
    spark_on_yarn_info=${spark_on_yarn_total#*\"entityStatus\"}
    spark_on_yarn_status=${spark_on_yarn_info#*\"}
    spark_on_yarn_status=${spark_on_yarn_status%%\"*}
    if [[ $spark_on_yarn_status == "GOOD_HEALTH" ]];then
        echo "Spark_on_Yarn : Good !"
    else
        echo "Spark_on_Yarn : Fail !"
        let error_num++
    fi
}

#sparkOnYarnCheck
function sparkOnYarnCheck()
{
    cloudera_res=$*

    sparkOnYarnInfo $cloudera_res
}

#hdfsInfo
function hdfsInfo()
{
    cloudera_res=$*

    #HDFS_BLOCKS_WITH_CORRUPT_REPLICAS
    block_with_corrupt_replicas=${cloudera_res#*\"HDFS_BLOCKS_WITH_CORRUPT_REPLICAS\"}
    block_with_corrupt_replicas_info=${block_with_corrupt_replicas#*\"summary\"}
    block_with_corrupt_replicas_status=${block_with_corrupt_replicas_info#*\"}
    block_with_corrupt_replicas_status=${block_with_corrupt_replicas_status%%\"*}
    if [[ $block_with_corrupt_replicas_status == "GOOD" ]];then
        echo "HDFS_BLOCKS_WITH_CORRUPT_REPLICAS : Good !"
    else
        echo "HDFS_BLOCKS_WITH_CORRUPT_REPLICAS : Fail !"
        let error_num++
    fi

    #HDFS_CANARY_HEALTH
    hdfs_canary_health=${cloudera_res#*\"HDFS_CANARY_HEALTH\"}
    hdfs_canary_health_info=${hdfs_canary_health#*\"summary\"}
    hdfs_canary_health_status=${hdfs_canary_health_info#*\"}
    hdfs_canary_health_status=${hdfs_canary_health_status%%\"*}
    if [[ $hdfs_canary_health_status == "GOOD" ]];then
        echo "HDFS_CANARY_HEALTH : Good !"
    else
        echo "HDFS_CANARY_HEALTH : Fail !"
        let error_num++
    fi

    #HDFS_DATA_NODES_HEALTHY
    data_nodes_healthy=${cloudera_res#*\"HDFS_DATA_NODES_HEALTHY\"}
    data_nodes_healthy_info=${data_nodes_healthy#*\"summary\"}
    data_nodes_healthy_status=${data_nodes_healthy_info#*\"}
    data_nodes_healthy_status=${data_nodes_healthy_status%%\"*}
    if [[ $data_nodes_healthy_status == "GOOD" ]];then
        echo "HDFS_DATA_NODES_HEALTHY : Good !"
    else
        echo "HDFS_DATA_NODES_HEALTHY : Fail !"
        let error_num++
    fi

    #HDFS_FREE_SPACE_REMAINING
    free_space_remaining=${cloudera_res#*\"HDFS_FREE_SPACE_REMAINING\"}
    free_space_remaining_info=${free_space_remaining#*\"summary\"}
    free_space_remaining_status=${free_space_remaining_info#*\"}
    free_space_remaining_status=${free_space_remaining_status%%\"*}
    if [[ $free_space_remaining_status == "GOOD" ]];then
        echo "HDFS_FREE_SPACE_REMAINING : Good !"
    else
        echo "HDFS_FREE_SPACE_REMAINING : Fail !"
        let error_num++
    fi

    #HDFS_HA_NAMENODE_HEALTH
    ha_namenode_health=${cloudera_res#*\"HDFS_HA_NAMENODE_HEALTH\"}
    ha_namenode_health_info=${ha_namenode_health#*\"summary\"}
    ha_namenode_health_status=${ha_namenode_health_info#*\"}
    ha_namenode_health_status=${ha_namenode_health_status%%\"*}
    if [[ $ha_namenode_health_status == "GOOD" ]];then
        echo "HDFS_HA_NAMENODE_HEALTH : Good !"
    else
        echo "HDFS_HA_NAMENODE_HEALTH : Fail !"
        let error_num++
    fi

    #HDFS_MISSING_BLOCKS
    missing_blocks=${cloudera_res#*\"HDFS_MISSING_BLOCKS\"}
    missing_blocks_info=${missing_blocks#*\"summary\"}
    missing_blocks_status=${missing_blocks_info#*\"}
    missing_blocks_status=${missing_blocks_status%%\"*}
    if [[ $missing_blocks_status == "GOOD" ]];then
        echo "HDFS_MISSING_BLOCKS : Good !"
    else
        echo "HDFS_MISSING_BLOCKS : Fail !"
        let error_num++
    fi

    #HDFS_UNDER_REPLICATED_BLOCKS
    under_replicated_blocks=${cloudera_res#*\"HDFS_UNDER_REPLICATED_BLOCKS\"}
    under_replicated_blocks_info=${under_replicated_blocks#*\"summary\"}
    under_replicated_blocks_status=${under_replicated_blocks_info#*\"}
    under_replicated_blocks_status=${under_replicated_blocks_status%%\"*}
    if [[ $under_replicated_blocks_status == "GOOD" ]];then
        echo "HDFS_UNDER_REPLICATED_BLOCKS : Good !"
    else
        echo "HDFS_UNDER_REPLICATED_BLOCKS : Fail !"
        let error_num++
    fi
}

#hdfsCheck
function hdfsCheck()
{
    cloudera_res=$*

    if [[ $cloudera_res =~ "HDFS" ]];then
        hdfs_total=${cloudera_res#*\"HDFS\"}
        hdfs_info=${hdfs_total#*\"entityStatus\"}
        hdfs_status=${hdfs_info#*\"}
        hdfs_status=${hdfs_status%%\"*}
        if [[ $hdfs_status == "GOOD_HEALTH" ]];then
            echo "HDFS : Good !"
        else
            hdfsInfo $cloudera_res
        fi
    else
        hdfsInfo $cloudera_res
    fi
}

#kafkaInfo
function kafkaInfo()
{
    cloudera_res=$*

    #KAFKA
    kafka=${cloudera_res#*\"KAFKA\"}
    kafka_info=${kafka#*\"entityStatus\"}
    kafka_status=${kafka_info#*\"}
    kafka_status=${kafka_status%%\"*}
    if [[ $kafka_status == "GOOD_HEALTH" ]];then
        echo "Kafka : Good !"
    else
        echo "Kafka : Fail !"
        let error_num++
    fi
}

#kafkaCheck
function kafkaCheck()
{
    cloudera_res=$*

    kafkaInfo $cloudera_res
}

#clouderaCheck
function clouderaCheck()
{
    cloudera_res=`service cloudera status`

    echo ""
    echo "================ Cloudera Status ================"
    echo ""

    echo "$cloudera_res"

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchCheck
function elasticsearchCheck()
{
    elasticsearch_res=`curl $es_server_ip:$es_http_port/_cluster/health?pretty 2>&1`

    echo ""
    echo "============== Elasticsearch Status ============="
    echo ""

    echo "$elasticsearch_res"

    echo ""
    echo "================================================="
    echo ""
}

#streamingCheck
function streamingCheck()
{
    streaming_res=`yarn application -list 2>&1`

    echo ""
    echo "================ Streaming Status ==============="
    echo ""

    echo "$streaming_res"

    echo ""
    echo "================================================="
    echo ""
}

#hbaseTableCheck
function hbaseTableCheck()
{
    #1.2 Not Used
    #select * from $schema_name.$relationship_tableName limit 10;
    #select * from $schema_name.$libconfig_tableName limit 10;

    hbase_table_res=`cd /usr/cdh/phoenix &&./bin/sqlline.py $zookeeper_quorum:$zookeeper_clientport:$hbase_znode 2>&1 1>/dev/null <<EOF
    select * from $schema_name.$blacklist_tableName limit 10;
    select * from $schema_name.$bigpic_tableName limit 10;
    select * from $schema_name.$history_tableName limit 10;
    select * from $schema_name.$alarm_tableName limit 10;
    !quit
EOF`

    echo ""
    echo "=============== HBase Table Status =============="
    echo ""

    echo "$hbase_table_res"

    echo ""
    echo "================================================="
    echo ""
}

#kafkaTopicCheck
function kafkaTopicCheck()
{
    topic_res=`cd /opt/cloudera/parcels/KAFKA/bin/ && ./kafka-topics --list --zookeeper $zookeeper_quorum:2181 2>&1`

    echo ""
    echo "=============== Kafka Topic Status =============="
    echo ""

    echo "$topic_res"

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchIndexCheck
function elasticsearchIndexCheck()
{

    #es_index_history_res=`curl --head $es_server_ip:$es_http_port/$es_index_history?pretty 2>&1`
    es_search_history_res=`curl --head $es_server_ip:$es_http_port/$es_search_history?pretty 2>&1`
    es_index_alarm_res=`curl --head $es_server_ip:$es_http_port/$es_index_alarm?pretty 2>&1`
    es_index_person_list_res=`curl --head $es_server_ip:$es_http_port/$es_index_person_list?pretty 2>&1`
	
    es_index_check_num=0
	while [ $es_index_check_num -le 35 ]
	do
        es_index_history_res[$es_index_check_num]=`curl --head $es_server_ip:$es_http_port/${es_index_array[$es_index_check_num]}?pretty 2>&1`
        es_index_check_num=$(( $es_index_check_num + 1 ))
	done
	
    echo ""
    echo "=========== Elasticsearch Index Status =========="
    echo ""


    #echo "$es_index_history_res"
    echo "$es_search_history_res"
    echo "$es_index_alarm_res"
    echo "$es_index_person_list_res"
	num=0
	while [ num -le 35 ]
	do
        echo${es_index_history_res[$num]}
	done
    echo ""
    echo "================================================="
    echo ""
}

#hbaseIndexerCheck
function hbaseIndexerCheck()
{
    hbase_main_res=`ps -ef | grep hbaseindexer | grep -v "grep" 2>&1`
    indexer_res=`/usr/local/hbase-indexer-1.6-SNAPSHOT/bin/hbase-indexer list-indexers`

    #echo ""
    echo "============== HBase Indexer Status ============="
    echo ""

    echo "$hbase_main_res"
    echo "$indexer_res"

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchPluginCheck
function elasticsearchPluginCheck()
{
    plugin_res=`cd /usr/elk/elasticsearch/ && ./bin/elasticsearch-plugin list`

    echo ""
    echo "============== Elasticsearch Plugin ============="
    echo ""

    echo "$plugin_res"

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchTaskCheck
function elasticsearchTaskCheck()
{
    task_res=`crontab -l`

    echo ""
    echo "=============== Elasticsearch Task =============="
    echo ""

    echo "$task_res"

    echo ""
    echo "================================================="
    echo ""
}

# Get Cloudera Cluster Hosts
function gethosts(){
  server_status=`service cloudera-scm-server status|grep "is running"`
  if [[ "$server_status" != "" ]]
  then
    curl -s -u admin:admin  -X GET http://$CDH_SERVER_IP:7180/api/v16/hosts > /tmp/cluster_hosts.tmp
    if [[ `cat /tmp/cluster_hosts.tmp` != "" ]]
    then
        cat /tmp/cluster_hosts.tmp |sed -n '/ipAddress/p' | sed 's/[ ,\",\,]//g' | awk -F: '{print $2}'
    else
        echo "Can't get the host ip of this cluster,please check the cloudera server's status"
    fi
  else
      echo -e "\033[31mCloudera Server is not running \033[0m"
  fi
  rm -rf /tmp/cluster_hosts.tmp
}

#diskFreeSpaceCheck
function diskFreeSpaceCheck()
{
  echo ""
  echo "============ Disk Free Space Check ==============="
  echo ""

  cluster_hosts=(`gethosts`)
  for host in ${cluster_hosts[*]}
  do
    echo "======== Current Node IP is : "$host " ========="
    ssh -Tq root@$host 'bash -s' < ./tools/diskCheck.sh 0
    echo "=================== End ========================"
  done

  echo ""
  echo "================================================="
  echo ""
}

#bigDataServiceCheck
function bigDataServiceCheck
{
    echo ""
    echo "================= Service Check ================="
    echo ""

    #cloudera 服务检查
    clouderaCheck

    #Spark Streaming 服务检查
    streamingCheck

    #HBase Table检查
    hbaseTableCheck

    #Kafka Topic检查
    kafkaTopicCheck
}

#bigDataSearchCheck
function bigDataSearchCheck
{
    echo ""
    echo "================== Search Check ================="
    echo ""

    #Elasticsearch 服务检查
    elasticsearchCheck

    #Elasticsearch Index检查
    elasticsearchIndexCheck

    #HBase Indexer检查
    hbaseIndexerCheck

    #Elasticsearch 插件检查
    elasticsearchPluginCheck

    #Elasticsearch 定时任务检查
    elasticsearchTaskCheck
}

#check
function check()
{
    echo ""
    echo "===================== Check ====================="
    echo ""

    #大数据服务引擎 检查
    bigDataServiceCheck

    #大数据搜索引擎 检查
    bigDataSearchCheck

    #磁盘使用空间检查
    diskFreeSpaceCheck
}

#clouderaSummary
function clouderaSummary()
{
    cloudera_res=`service cloudera status`

    echo ""
    echo "================ Cloudera Summary ==============="
    echo ""

    #HBase
    hbaseCheck $cloudera_res

    #ZooKeeper
    zookeeperCheck $cloudera_res

    #Oozie
    oozieCheck $cloudera_res

    #Yarn
    yarnCheck $cloudera_res

    #Spark on Yarn
    sparkOnYarnCheck $cloudera_res

    #HDFS
    hdfsCheck $cloudera_res

    #Kafka
    kafkaCheck $cloudera_res

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchSummary
function elasticsearchSummary()
{
    elasticsearch_res=`curl $es_server_ip:$es_http_port/_cluster/health?pretty 2>&1`

    echo ""
    echo "============= Elasticsearch Summary ============="
    echo ""

    elasticsearch_cluster_name=${elasticsearch_res#*\"cluster_name\"}
    elasticsearch_cluster_name=${elasticsearch_cluster_name#*\"}
    elasticsearch_cluster_name=${elasticsearch_cluster_name%%\"*}

    elasticsearch_cluster_status=${elasticsearch_res#*\"status\"}
    elasticsearch_cluster_status=${elasticsearch_cluster_status#*\"}
    elasticsearch_cluster_status=${elasticsearch_cluster_status%%\"*}

    if [[ $elasticsearch_cluster_status == "yellow" || $elasticsearch_cluster_status == "green" ]];then
        echo "Cluster Name : $elasticsearch_cluster_name"
        echo "Status : Good !"
    else
        echo "Cluster Name : $elasticsearch_cluster_name"
        echo "Status : Fail !"
        let error_num++
    fi

    echo ""
    echo "================================================="
    echo ""
}

#streamingSummary
function streamingSummary()
{
    streaming_res=`yarn application -list 2>&1`
    #字符串操作
    streaming_num=${streaming_res#*RUNNING]):}
    streaming_num=${streaming_num:0:1}

    echo ""
    echo "=============== Streaming Summary ==============="
    echo ""

    if [[ $streaming_num == "0" || $streaming_num == "1" ]]; then
        if [[ $streaming_res =~ $application_name ]];then
            echo "Application Name : $application_name"
            echo "Status : Running !"
        else
            echo "No Application Running !"
        fi
    else
        echo "Error : More Than Two Applications Running !"
        let error_num++
    fi

    echo ""
    echo "================================================="
    echo ""
}

#hbaseTableSummary
function hbaseTableSummary()
{
    #1.2 Not Used
    #select * from $schema_name.$relationship_tableName limit 10;
    #select * from $schema_name.$libconfig_tableName limit 10;

    hbase_table_res=`cd /usr/cdh/phoenix &&./bin/sqlline.py $zookeeper_quorum:$zookeeper_clientport:$hbase_znode 2>&1 1>/dev/null <<EOF
    select * from $schema_name.$blacklist_tableName limit 10;
    select * from $schema_name.$bigpic_tableName limit 10;
    select * from $schema_name.$history_tableName limit 10;
    select * from $schema_name.$alarm_tableName limit 10;
    !quit
EOF`

    echo ""
    echo "============== HBase Table Summary =============="
    echo ""

    #if [[ $hbase_table_res =~ $schema_name.$task_tableName ]];then (Not Used)
    #    echo "$schema_name.$task_tableName : Error !"
    #else
    #    echo "$schema_name.$task_tableName : Exist !"
    #fi

    #if [[ $hbase_table_res =~ $schema_name.$cameralib_tableName ]];then
    #    echo "$schema_name.$task_tableName : Error !"
    #    let error_num++
    #else
    #    echo "$schema_name.$cameralib_tableName : Exist !"
    #fi

    if [[ $hbase_table_res =~ $schema_name.$blacklist_tableName ]];then
        echo "$schema_name.$blacklist_tableName : Error !"
        let error_num++
    else
        echo "$schema_name.$blacklist_tableName : Exist !"
    fi

    #if [[ $hbase_table_res =~ $schema_name.$relationship_tableName ]];then (Not Used)
    #    echo "$schema_name.$relationship_tableName : Error !"
    #    let error_num++
    #else
    #    echo "$schema_name.$relationship_tableName : Exist !"
    #fi

    #if [[ $hbase_table_res =~ $schema_name.$libconfig_tableName ]];then (Not Used)
    #    echo "$schema_name.$libconfig_tableName : Error !"
    #    let error_num++
    #else
    #    echo "$schema_name.$libconfig_tableName : Exist !"
    #fi

    if [[ $hbase_table_res =~ $schema_name.$bigpic_tableName ]];then
        echo "$schema_name.$bigpic_tableName : Error !"
        let error_num++
    else
        echo "$schema_name.$bigpic_tableName : Exist !"
    fi

    if [[ $hbase_table_res =~ $schema_name.$history_tableName ]];then
        echo "$schema_name.$history_tableName : Error !"
        let error_num++
    else
        echo "$schema_name.$history_tableName : Exist !"
    fi

    if [[ $hbase_table_res =~ $schema_name.$alarm_tableName ]];then
        echo "$schema_name.$alarm_tableName : Error !"
        let error_num++
    else
        echo "$schema_name.$alarm_tableName : Exist !"
    fi

    #if [[ $hbase_table_res =~ $schema_name.$oldman_tableName ]];then (Not Used)
    #    echo "$schema_name.$oldman_tableName : Error !"
    #else
    #    echo "$schema_name.$oldman_tableName : Exist !"
    #fi

    echo ""
    echo "================================================="
    echo ""
}

#kafkaTopicSummary
function kafkaTopicSummary()
{
    topic_res=`cd /opt/cloudera/parcels/KAFKA/bin/ && ./kafka-topics --list --zookeeper $zookeeper_quorum:2181 2>&1`

    echo ""
    echo "============== Kafka Topic Summary =============="
    echo ""

    topic_consumer=${topic_res#*__consumer_offsets}

    #删除__consumer_offsets后面几行INFO日志信息
    topic_consumer=${topic_consumer%%18*}

    if [[ $topic_res =~ $topic_analysis_name ]];then
        echo "$topic_analysis_name Status : Exist !"
    else
        echo "$topic_analysis_name Status : Error !"
        let error_num++
    fi

    if [[ $topic_res =~ $topic_blacklistchange_name ]];then
        echo "$topic_blacklistchange_name Status : Exist !"
    else
        echo "$topic_blacklistchange_name Status : Error !"
        let error_num++
    fi

    if [[ $topic_res =~ $topic_alarm_name ]];then
        echo "$topic_alarm_name Status : Exist !"
    else
        echo "$topic_alarm_name Status : Error !"
        let error_num++
    fi

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchIndexSummary
function elasticsearchIndexSummary()
{

    #es_index_history_res=`curl --head $es_server_ip:$es_http_port/$es_index_history?pretty 2>&1`
    es_search_history_res=`curl --head $es_server_ip:$es_http_port/$es_search_history?pretty 2>&1`
    es_index_alarm_res=`curl --head $es_server_ip:$es_http_port/$es_index_alarm?pretty 2>&1`
    es_index_person_list_res=`curl --head $es_server_ip:$es_http_port/$es_index_person_list?pretty 2>&1`
	es_index_check_num=0
	while [ $es_index_check_num -le 35 ]
	do
        es_index_history_res[$es_index_check_num]=`curl --head $es_server_ip:$es_http_port/${es_index_array[$es_index_check_num]}?pretty 2>&1`
        es_index_check_num=$(( $es_index_check_num + 1 ))
	done
    echo ""
    echo "========== Elasticsearch Index Summary =========="
    echo ""

	num=0
	while [ $num -le 35 ]
	do
        es_index_history_res[$num]=`curl --head $es_server_ip:$es_http_port/${es_index_array[$es_index_check_num]}?pretty 2>&1`
		if [[ ${es_index_history_res[$num]} =~ "HTTP/1.1 200 OK" ]];then
			status=Exist 
        else
			status=Error
			let error_num++
        fi
		num=$(( $num + 1 ))
	done
	echo "History index Status : $status !"
    if [[ $es_search_history_res =~ "HTTP/1.1 200 OK" ]];then
        echo "History Search Status : Exist !"
    else
        echo "History Search Status : Error !"
        let error_num++
    fi

    if [[ $es_index_alarm_res =~ "HTTP/1.1 200 OK" ]];then
        echo "Alarm Index Status : Exist !"
    else
        echo "Alarm Index Status : Error !"
        let error_num++
    fi

    if [[ $es_index_person_list_res =~ "HTTP/1.1 200 OK" ]];then
        echo "Person List Index Status : Exist !"
    else
        echo "Person List Index Status : Error !"
        let error_num++
    fi

    echo ""
    echo "================================================="
    echo ""
}

#hbaseIndexerSummary
function hbaseIndexerSummary()
{
    hbase_main_res=`ps -ef | grep hbaseindexer | grep -v "grep" 2>&1`
    indexer_res=`/usr/local/hbase-indexer-1.6-SNAPSHOT/bin/hbase-indexer list-indexers`

    echo ""
    echo "============= HBase Indexer Summary ============="
    echo ""

    if [[ $hbase_main_res =~ "hbaseindexer.Main" ]];then
        echo "HBase Indexer Status : Exist !"
    else
        echo "HBase Indexer Status : Error !"
        let error_num++
    fi

    if [[ $indexer_res =~ "alarm" ]];then
        echo "Alarm Indexer : Exist !"
    else
        echo "Alarm Indexer : Error !"
        let error_num++
    fi

    if [[ $indexer_res =~ "history" ]];then
        echo "History Indexer : Exist !"
    else
        echo "History Indexer : Error !"
        let error_num++
    fi

    if [[ $indexer_res =~ "person" ]];then
        echo "Person Indexer : Exist !"
    else
        echo "Person Indexer : Error !"
        let error_num++
    fi

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchPluginSummary
function elasticsearchPluginSummary()
{
    plugin_res=`cd /usr/elk/elasticsearch/ && ./bin/elasticsearch-plugin list`

    echo ""
    echo "========== Elasticsearch Plugin Summary ========="
    echo ""

    echo "Elasticsearch Plugin:"
    echo "$plugin_res"

    echo ""
    echo "================================================="
    echo ""
}

#elasticsearchIndexerSummary
function elasticsearchTaskSummary()
{
    task_res=`ssh $ES_HOST crontab -l`

    echo ""
    echo "=========== Elasticsearch Task Summary =========="
    echo ""

    if [[ $task_res =~ "fss_history_action_file" ]];then
        echo "fss_history_action_file Status : Exist !"
    else
        echo "fss_history_action_file Status : Error !"
        let error_num++
    fi

    if [[ $task_res =~ "fss_history_search_action_file" ]];then
        echo "fss_history_search_action_file.yml Status : Exist !"
    else
        echo "fss_history_search_action_file Status : Error !"
        let error_num++
    fi

    echo ""
    echo "================================================="
    echo ""
}

#diskFreeSpaceSummary
function diskFreeSpaceSummary()
{
    echo ""
    echo "============ Disk FreeSpace Summary ==========="
    echo ""

    cluster_hosts=(`gethosts`)
    for host in ${cluster_hosts[*]}
    do
      ssh -Tq root@$host 'bash -s' < ./tools/diskCheck.sh 1
      if [ $? -ne 0 ];then
         let error_num++
      fi
    done

    if [ "$error_num" = "0" ];then
       echo " disk free space : GOOD !!!"
    else
       echo " disk free space : ERROR !!!"
    fi
    echo ""
    echo "================================================="
    echo ""
}

#bigDataServiceSummary
function bigDataServiceSummary
{
    echo ""
    echo "================ Service Summary ================"
    echo ""

    #Cloudera 总结
    clouderaSummary

    #Spark Streaming 总结
    streamingSummary

    #HBase Table总结
    hbaseTableSummary

    #Kafka Topic总结
    kafkaTopicSummary
}

#bigDataSearchSummary
function bigDataSearchSummary
{
    echo ""
    echo "================= Search Summary ================"
    echo ""

    #Elasticsearch 总结
    elasticsearchSummary

    #Elasticsearch Index总结
    elasticsearchIndexSummary

    #HBase Indexer总结
    hbaseIndexerSummary

    #Elasticsearch Plugin总结
    elasticsearchPluginSummary

    #Elasticsearch Task总结
    #elasticsearchTaskSummary
}

#errorSummary
function errorSummary
{
    if [[ $error_num == 0 ]];then
        echo "All Service Success !"
    else
        echo "$error_num Errors Found !"
    fi

    echo ""
    echo "================================================="
    echo ""
}

#summary
function summary()
{
    echo ""
    echo "==================== Summary ===================="
    echo ""

    #大数据服务引擎 总结
    bigDataServiceSummary

    #大数据搜索引擎 总结
    bigDataSearchSummary

    #磁盘使用空间检查
    diskFreeSpaceSummary

    #错误总数
    errorSummary
}

#initParam
function initParam()
{
    error_num=0
}

#info
function info()
{
    echo ""
    echo "================================ERROR: wrong arguments!================================================="
    echo "===================================Check Explanation===================================================="
    echo " ./fss_check.sh check                    :                Check the Services "
    echo " ./fss_check.sh service_check            :                Check the Service Engine "
    echo " ./fss_check.sh search_check             :                Check the Service Engine "
	echo " ./fss_check.sh disk_check               :                Check the Disk Space "
    echo " ./fss_check.sh summary es_ip            :                Summary the services "
    echo " ./fss_check.sh service_summary es_ip    :                Summary the Service Engine "
    echo " ./fss_check.sh search_summary es_ip     :                Summary the Search Engine "
	echo " ./fss_check.sh disk_summary             :                Summary the Disk Space "
    echo "========================================================================================================"
    echo ""
}

#menu
function menu()
{
    initParam

    choose=$1
    case $choose in
        check )
            check
            ;;
        service_check )
            bigDataServiceCheck
            ;;
        search_check )
            bigDataSearchCheck
            ;;
        disk_check )
            diskFreeSpaceCheck
            ;;
        summary )
            summary
            ;;
        service_summary )
            bigDataServiceSummary
            ;;
        search_summary )
            bigDataSearchSummary
            ;;
        disk_summary )
            diskFreeSpaceSummary
            ;;
        * )
            info
            exit 1
            ;;
    esac
}

#main
function main()
{
    if [[ $1 == "" ]];then
        info
    else
        menu $1
    fi
}

#============================== main ==============================

main $1

