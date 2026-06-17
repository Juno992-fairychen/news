drop table  if  exists  dws_interaction_news_like_1d;
CREATE  EXTERNAL  TABLE  dws_interaction_news_like_1d(
`news_id` int,
`title` string,
`platform` string,
`author` string,
`type` string,
`like_add_count_1d` BIGINT
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/dws/dws_interaction_news_like_1d';