drop  table  if  exists  dws_flow_news_click_1d;
CREATE  EXTERNAL  TABLE  dws_flow_news_click_1d(
`news_id` int,
`title` string,
`platform` string,
`author` string,
`type` string,
`action` string,
`exposure_type` string,
`click_add_count_1d` BIGINT
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/dws/dws_flow_news_click_1d';