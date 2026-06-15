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
#互动域新闻粒度收藏新闻最近1日汇总表
dws_interaction_news_favorite_1d="
insert overwrite table $DB_NAME.dws_interaction_news_favorite_1d partition(dt='$dt')
select 
tmp.news_id,
dim.title,
dim.platform,
dim.author,
dim.type,
favorite_add_count_1d 
from 
(
select
news_id,
count(*) favorite_add_count_1d 
from $DB_NAME.dwd_interaction_favorite_inc
where dt='$dt' 
group by news_id
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
#互动域新闻粒度点赞新闻最近1日汇总表
dws_interaction_news_like_1d="
insert overwrite table $DB_NAME.dws_interaction_news_like_1d partition(dt='$dt')
select 
tmp.news_id,
dim.title,
dim.platform,
dim.author,
dim.type,
like_add_count_1d 
from 
(
select
news_id,
count(*) like_add_count_1d 
from $DB_NAME.dwd_interaction_like_inc
where dt='$dt' 
group by news_id
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
#互动域新闻粒度转发新闻最近1日汇总表
dws_interaction_news_repost_1d="
insert overwrite table $DB_NAME.dws_interaction_news_repost_1d partition(dt='$dt')
select 
tmp.news_id,
dim.title,
dim.platform,
dim.author,
dim.type,
repost_add_count_1d 
from 
(
select
news_id,
count(*) repost_add_count_1d 
from $DB_NAME.dwd_interaction_repost_inc
where dt='$dt' 
group by news_id
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
#互动域用户粒度评论新闻最近1日汇总表
dws_interaction_user_comment_1d="
insert overwrite table $DB_NAME.dws_interaction_user_comment_1d partition(dt='$dt')
select 
tmp.user_id,
dim.gender,
dim.age,
dim.city,
dim.device_type,
dim.active,
comment_add_count_1d 
from 
(
select
user_id,
count(*) comment_add_count_1d 
from $DB_NAME.dwd_interaction_comment_inc
where dt='$dt' 
group by user_id
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

execute_sql() {
    # 动态把拼接好的变量 SQL 传给 Beeline 执行
    $HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "$1"
}

#条件选择
case $1 in
"dws_interaction_news_favorite_1d" )
	execute_sql "$dws_interaction_news_favorite_1d"
	;;
"dws_interaction_news_like_1d" )
	execute_sql "$dws_interaction_news_like_1d"
	;;
"dws_interaction_news_repost_1d" )
	execute_sql "$dws_interaction_news_repost_1d"
	;;
"dws_interaction_user_comment_1d" )
	execute_sql "$dws_interaction_user_comment_1d"
	;;
esac 
