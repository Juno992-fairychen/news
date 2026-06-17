drop  table  if  exists  ads_flow_avg_stay_time_top10;
CREATE  EXTERNAL  TABLE  ads_flow_avg_stay_time_top10(
`dt` string,
`news_id` int,
`title` string,
`platform` string,
`author` string,
`type` string,
`avg_stay_time` bigint
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/ads/ads_flow_avg_stay_time_top10';