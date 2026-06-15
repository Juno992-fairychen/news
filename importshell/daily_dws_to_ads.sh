#!/bin/bash
# 修复一：对齐你实际的 Hive 4.0 安装目录
HIVE_HOME=/opt/module/hive-4.0.0
# 数据库名称
DB_NAME=news

# 如果参数为空，dt默认为前一天的日期
if [ -n "$2" ] ;then
    dt=$2
else
    dt=`date -d "-1 day" +%F`
fi

# =====================================================================
# 核心重构说明：以下所有 SQL 均已剔除低效的 UNION 历史表操作，
# 改为直接利用 PARTITION(dt='$dt') 机制精确定位当天分区，实现 O(1) 级跑批性能！
# =====================================================================

# 各类别新闻点赞次数Top3
ads_news_like_count_top3_by_type="
insert overwrite table $DB_NAME.ads_news_like_count_top3_by_type partition(dt='$dt')
select 
type,
news_id,
title,
author,
cast(like_add_count_1d as bigint),
rank 
from 
(
select 
type,
news_id,
title,
author,
like_add_count_1d,
rank() over (partition by type order by cast(like_add_count_1d as int) desc) rank 
from $DB_NAME.dws_interaction_news_like_1d
where dt='$dt'
)tmp
where rank<=3;
"

# 各平台新闻收藏次数Top3
ads_news_favorite_count_top3_by_platform="
insert overwrite table $DB_NAME.ads_news_favorite_count_top3_by_platform partition(dt='$dt')
select 
platform,
news_id,
title,
author,
cast(favorite_add_count_1d as bigint),
rank 
from 
(
select 
platform,
news_id,
title,
author,
favorite_add_count_1d,
rank() over (partition by platform order by cast(favorite_add_count_1d as int) desc) rank 
from $DB_NAME.dws_interaction_news_favorite_1d
where dt='$dt'
)tmp
where rank<=3;
"

# 每日新闻点赞、收藏、转发次数
ads_news_stats="
with
tmp_like as 
(
select 
sum(cast(like_add_count_1d as int)) like_count
from $DB_NAME.dws_interaction_news_like_1d where dt='$dt'
),
tmp_favorite as 
(
select
sum(cast(favorite_add_count_1d as int)) favorite_count
from $DB_NAME.dws_interaction_news_favorite_1d where dt='$dt'
),
tmp_repost as 
(
select
sum(cast(repost_add_count_1d as int)) repost_count
from $DB_NAME.dws_interaction_news_repost_1d where dt='$dt'
)
insert overwrite table $DB_NAME.ads_news_stats partition(dt='$dt')
select
sum(like_count),
sum(favorite_count),
sum(repost_count) 
from 
(
select like_count, 0 favorite_count, 0 repost_count from tmp_like
union all
select 0 like_count, favorite_count, 0 repost_count from tmp_favorite
union all
select 0 like_count, 0 favorite_count, repost_count from tmp_repost
)tmp;
"

# 活跃用户在评论中的占比
ads_user_comment_count_by_active="
insert overwrite table $DB_NAME.ads_user_comment_count_by_active partition(dt='$dt')
select 
active,
sum(cast(comment_add_count_1d as bigint)) comment_count
from $DB_NAME.dws_interaction_user_comment_1d
where dt='$dt'
group by active;
"

# 男女各自关注度最高的新闻Top3
ads_user_view_count_top3_by_gender="
with tmp_view as (
select
gender,
news_id,
sum(cast(view_count_1d as int)) as view_count
from 
$DB_NAME.dws_flow_user_news_page_view_1d
where dt='$dt'
group by gender,news_id
)
insert overwrite table $DB_NAME.ads_user_view_count_top3_by_gender partition(dt='$dt')
select 
gender,
tmp.news_id,
title,
platform,
author,
type,
view_count,
rank 
from 
(
select 
gender,
news_id,
view_count,
rank() over (partition by gender order by view_count desc) rank 
from tmp_view
)tmp
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
) dim on tmp.news_id=dim.news_id
where rank<=3;
"

# 每日新闻资讯点击率
ads_flow_click_count_by_action="
insert overwrite table $DB_NAME.ads_flow_click_count_by_action partition(dt='$dt')
select 
action,
sum(cast(click_add_count_1d as bigint)) click_count
from $DB_NAME.dws_flow_news_click_1d
where dt='$dt'
group by action;
"

# 单个页面的平均访问时长Top10
ads_flow_avg_stay_time_top10="
with tmp_view as (
select
news_id,
avg(cast(stay_time_1d as double)) as avg_stay_time
from 
$DB_NAME.dws_flow_user_news_page_view_1d
where dt='$dt'
group by news_id
)
insert overwrite table $DB_NAME.ads_flow_avg_stay_time_top10 partition(dt='$dt')
select
tmp_view.news_id,
title,
platform,
author,
type,
avg_stay_time
from tmp_view
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
) dim on tmp_view.news_id=dim.news_id
order by avg_stay_time desc
limit 10;
"

# 所有页面加载时间的平均值、最大值和最小值
ads_flow_avg_max_min_loading_time="
insert overwrite table $DB_NAME.ads_flow_avg_max_min_loading_time partition(dt='$dt')
select
CAST(avg(cast(avg_load_time_1d as double)) AS DECIMAL(10, 1)) avg_load_time,
max(cast(max_load_time_1d as double)) max_load_time,
min(cast(min_load_time_1d as double)) min_load_time 
from $DB_NAME.dws_flow_visitor_news_page_loading_1d
where dt='$dt';
"

# 修复二：封装公共的 Beeline 远程连接安全执行器
execute_sql() {
    $HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno -e "use news; $1"
}

#  修复三：条件选择，为分支变量加上双引号，对准统一执行函数
case "$1" in
"ads_news_like_count_top3_by_type")
	execute_sql "$ads_news_like_count_top3_by_type"
	;;
"ads_news_favorite_count_top3_by_platform")
	execute_sql "$ads_news_favorite_count_top3_by_platform"
	;;
"ads_news_stats")
	execute_sql "$ads_news_stats"
	;;
"ads_user_comment_count_by_active")
	execute_sql "$ads_user_comment_count_by_active"
	;;
"ads_user_view_count_top3_by_gender")
	execute_sql "$ads_user_view_count_top3_by_gender"
	;;
"ads_flow_click_count_by_action")
	execute_sql "$ads_flow_click_count_by_action"
	;;
"ads_flow_avg_stay_time_top10")
	execute_sql "$ads_flow_avg_stay_time_top10"
	;;
"ads_flow_avg_max_min_loading_time")
	execute_sql "$ads_flow_avg_max_min_loading_time"
	;;
*)
	echo "错误: 未知的ADS层应用指标分支名！"
	exit 1
	;;
esac
