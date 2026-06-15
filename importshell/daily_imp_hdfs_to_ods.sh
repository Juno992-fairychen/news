#!/bin/bash
# Hadoop安装目录
HADOOP_HOME=/opt/module/hadoop-3.3.6
# Hive安装目录
HIVE_HOME=/opt/module/hive-4.0.0

# 如果参数为空，dt默认为前一天的日期
if [ -n "$2" ] ;then
    dt=$2
else
    dt=`date -d "-1 day" +%F`
fi

# 数据装载函数
load_data() {
    sql=""
    # 检查 HDFS 源头目录是否存在
    $HADOOP_HOME/bin/hdfs dfs -test -e "$1"
    if [[ $? -eq 0 ]]; then
        sql="load data inpath '$1' $2;"
        # 使用标准的 Beeline 远程连接执行
        $HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "use news; $sql"
    else
        echo "警告: HDFS 源头路径 $1 不存在，跳过本次数据装载！"
    fi
}

# 根据第一个参数决定执行哪个同步分支
case "$1" in
"ods_user_info_full")
  # 🌟 严格对齐现实：user_info 带 dt 文件夹
  load_data "/original/news/table/user_info/dt=$dt" "overwrite into table news.ods_user_info_full partition(dt='$dt')"
  ;;
"ods_news_info_full")
  # 🌟 严格对齐现实：news_info 带 dt 文件夹
  load_data "/original/news/table/news_info/dt=$dt" "overwrite into table news.ods_news_info_full partition(dt='$dt')"
  ;;
"ods_date_info_full")
  # 🌟 严格对齐现实：date_info 光秃秃，不带 dt 文件夹
  load_data "/original/news/table/date_info" "overwrite into table news.ods_date_info_full"
  ;;
*)
  echo "错误: 未知的表名参数！"
  exit 1
  ;;
esac

