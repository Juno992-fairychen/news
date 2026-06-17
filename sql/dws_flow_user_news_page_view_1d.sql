drop  table  if  exists  dws_flow_user_news_page_view_1d;
CREATE  EXTERNAL  TABLE  dws_flow_user_news_page_view_1d(
`user_id` int,
`gender` int,
`age` int,
`city` string,
`device_type` string,
`active` int,
`news_id` int,
`entrance` string,
`stay_time_1d` BIGINT,
`view_count_1d` BIGINT
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/dws/dws_flow_user_news_page_view_1d';