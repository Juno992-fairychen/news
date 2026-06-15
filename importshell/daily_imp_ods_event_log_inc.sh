#!/bin/bash
#hadoop安装目录
HIVE_HOME=/opt/module/hive-4.0.0
#如果参数为空，dt默认为前一天的日期
if [ -n "$1" ] ;then
    dt=$1
else
    dt=`date -d "-1 day" +%F`
fi
#hive 导入数据的sql命令
sql="insert overwrite table news.ods_event_log_inc partition(dt='$dt') select * from news.newslogs where substring(id,9,10)='$dt';"
#hive客户端执行sql语句
$HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "$sql"
