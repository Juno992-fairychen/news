#!/bin/bash
#Hive安装目录
HIVE_HOME=/opt/module/hive-4.0.0
#数据库名称
DB_NAME=news
#如果参数为空，dt默认为前一天的日期
if [ -n "$2" ] ;then
    dt=$2
else
    dt=`date -d "-1 day" +%F`
fi

dwd_flow_click_inc="
insert overwrite table $DB_NAME.dwd_flow_click_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.action') action,
get_json_object(event_json,'$.news_id') news_id,
get_json_object(event_json,'$.order') page_order,
get_json_object(event_json,'$.news_type') news_type,
get_json_object(event_json,'$.exposure_type') exposure_type,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='click';
"
dwd_flow_news_detail_inc="
insert overwrite table $DB_NAME.dwd_flow_news_detail_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.entrance') entrance,
get_json_object(event_json,'$.action') action,
get_json_object(event_json,'$.news_id') news_id,
get_json_object(event_json,'$.stay_time') stay_time,
get_json_object(event_json,'$.load_time') load_time,
get_json_object(event_json,'$.ecc') ecc,
get_json_object(event_json,'$.news_type') news_type,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='news_detail';
"

dwd_flow_news_list_inc="
insert overwrite table $DB_NAME.dwd_flow_news_list_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.action') action,
get_json_object(event_json,'$.load_time') load_time,
get_json_object(event_json,'$.load_way') load_way,
get_json_object(event_json,'$.load_type') load_type,
get_json_object(event_json,'$.ecc') ecc,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='loading';
"

dwd_interaction_comment_inc="
insert overwrite table $DB_NAME.dwd_interaction_comment_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.user_id') user_id,
get_json_object(event_json,'$.news_id') news_id,
get_json_object(event_json,'$.content') content,
get_json_object(event_json,'$.add_time') add_time,
get_json_object(event_json,'$.like_num') like_num,
get_json_object(event_json,'$.reply_num') reply_num,
get_json_object(event_json,'$.stay_time') stay_time,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='comment';
"

dwd_interaction_favorite_inc="
insert overwrite table $DB_NAME.dwd_interaction_favorite_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.news_id') news_id,
get_json_object(event_json,'$.user_id') user_id,
get_json_object(event_json,'$.add_time') add_time,
get_json_object(event_json,'$.stay_time') stay_time,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='favorite';
"

dwd_interaction_like_inc="
insert overwrite table $DB_NAME.dwd_interaction_like_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.user_id') user_id,
get_json_object(event_json,'$.news_id') news_id,
get_json_object(event_json,'$.add_time') add_time,
get_json_object(event_json,'$.stay_time') stay_time,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='like';
"

dwd_interaction_repost_inc="
insert overwrite table $DB_NAME.dwd_interaction_repost_inc partition(dt='$dt') 
select 
mid,
uid,
vc,
vn,
lan,
source,
os,
area,
model,
brand,
resolution,
app_time,
network,
lon,
lat,
get_json_object(event_json,'$.user_id') user_id,
get_json_object(event_json,'$.news_id') news_id,
get_json_object(event_json,'$.add_time') add_time,
get_json_object(event_json,'$.stay_time') stay_time,
event_time 
from $DB_NAME.dwd_base_event_log_inc where dt='$dt' and event_name='repost';
"

execute_sql() {
    # 动态把拼接好的变量 SQL 传给 Beeline 执行
    $HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "$1"
}

# 根据传入的第一个参数（分支表名）决定调用哪个 SQL 变量
# 为 $1 加上双引号可以有效防止参数为空时脚本报错崩溃
case "$1" in
"dwd_flow_click_inc")
        execute_sql "$dwd_flow_click_inc"
        ;;
"dwd_flow_news_detail_inc")
        execute_sql "$dwd_flow_news_detail_inc"
        ;;
"dwd_flow_news_list_inc")
        execute_sql "$dwd_flow_news_list_inc"
        ;;
"dwd_interaction_comment_inc")
        execute_sql "$dwd_interaction_comment_inc"
        ;;
"dwd_interaction_favorite_inc")
        execute_sql "$dwd_interaction_favorite_inc"
        ;;
"dwd_interaction_like_inc")
        execute_sql "$dwd_interaction_like_inc"
        ;;
"dwd_interaction_repost_inc")
        execute_sql "$dwd_interaction_repost_inc"
        ;;
*)
        echo "错误: 未知的事件分支表名！"
        exit 1
        ;;
esac
