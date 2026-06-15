#!/bin/bash
# Hive安装目录
HIVE_HOME=/opt/module/hive-4.0.0

# 修复一：规范参数判断。如果传入第二个参数则为指定日期，否则默认为昨天
if [ -n "$2" ] ;then
    dt=$2
else
    dt=`date -d "-1 day" +%F`
fi

# 修复二：在目标表名前强行加上 news. 库名，确保数据能精准走入你刚刚规范好的 /dim/ 物理路径下
# 用户维度表导入语句
dim_user_info_full="insert overwrite table news.dim_user_info_full partition(dt='$dt') select user_id,user_name,gender,age,phone,province,city,device_type,active,modify_date,create_date from news.ods_user_info_full where dt='$dt';"

# 新闻维度表导入语句
dim_news_info_full="insert overwrite table news.dim_news_info_full partition(dt='$dt') select news_id,title,platform,author,type,length,comment_num,publish_time,img_url,doc_url from news.ods_news_info_full where dt='$dt';"

# 时间维度表导入语句
dim_date_info="insert overwrite table news.dim_date_info select * from news.ods_date_info_full;"

# 修复三：使用标准的 Beeline 远程连接执行函数，避免直接调用 hive -e 报错
execute_sql() {
    $HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "use news; $1"
}

# 修复四：为 $1 加上双引号，防止参数为空时 case 语法报错
case "$1" in
"dim_user_info_full")
  execute_sql "$dim_user_info_full"
  ;;
"dim_news_info_full")
  execute_sql "$dim_news_info_full"
  ;;
"dim_date_info")
  execute_sql "$dim_date_info"
  ;;
*)
  echo "错误: 未知的表名参数！可用参数: dim_user_info_full | dim_news_info_full | dim_date_info"
  exit 1
  ;;
esac
