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
#流量域新闻粒度页面点击/曝光最近1日汇总表
dws_flow_news_click_1d="
insert overwrite table $DB_NAME.dws_flow_news_click_1d partition(dt='$dt')
select 
tmp.news_id,
dim.title,
dim.platform,
dim.author,
dim.type,
tmp.action,
tmp.exposure_type,
tmp.click_add_count_1d 
from 
(
select
news_id,
action,
exposure_type,
count(*) click_add_count_1d 
from $DB_NAME.dwd_flow_click_inc
where dt='$dt' 
group by news_id,action,exposure_type
) tmp 
left join
(
select 
news_id,
title,
platform,
author,
type 
from $DB_NAME.dim_news_info_full
where dt='$dt'
) dim on tmp.news_id=dim.news_id;
"
#流量域用户新闻粒度浏览时长和访问次数最近1日汇总表
dws_flow_user_news_page_view_1d="
insert overwrite table $DB_NAME.dws_flow_user_news_page_view_1d partition(dt='$dt')
select 
tmp.user_id,
dim.gender,
dim.age,
dim.city,
dim.device_type,
dim.active,
tmp.news_id,
tmp.entrance,
tmp.stay_time_1d,
tmp.view_count_1d 
from 
(
select
uid as user_id,
news_id,
entrance,
sum(cast(stay_time as int)) stay_time_1d,
count(*) view_count_1d 
from $DB_NAME.dwd_flow_news_detail_inc
where dt='$dt' and action=2
group by uid,news_id,entrance
) tmp 
left join
(
select 
user_id,
gender,
age,
city,
device_type,
active  
from $DB_NAME.dim_user_info_full
where dt='$dt'
) dim on tmp.user_id=dim.user_id;
"
#互动域新闻粒度页面加载时长新闻最近1日汇总表
dws_flow_visitor_news_page_loading_1d="
insert overwrite table $DB_NAME.dws_flow_visitor_news_page_loading_1d partition(dt='$dt')
select 
mid,
os,
brand,
model,
network,
news_id,
entrance,
AVG(cast(load_time as double)) avg_load_time_1d,
MAX(cast(load_time as double)) max_load_time_1d,
MIN(cast(load_time as double)) min_load_time_1d
from $DB_NAME.dwd_flow_news_detail_inc
where dt='$dt' and action=2
group by mid,os,brand,model,network,news_id,entrance;
"

execute_sql() {
    # 动态把拼接好的变量 SQL 传给 Beeline 执行
    $HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "use news; $1"
}

# 为 $1 加上双引号可以有效防止参数为空时脚本崩溃
case "$1" in
"dws_flow_news_click_1d")
        execute_sql "$dws_flow_news_click_1d"
        ;;
"dws_flow_user_news_page_view_1d")
        execute_sql "$dws_flow_user_news_page_view_1d"
        ;;
"dws_flow_visitor_news_page_loading_1d")
        execute_sql "$dws_flow_visitor_news_page_loading_1d"
        ;;
*)
        echo "错误: 未知的流量域事件分支表名！"
        exit 1
        ;;
esac
