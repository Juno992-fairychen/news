drop table if exists ods_news_info_full;
CREATE EXTERNAL TABLE ods_news_info_full (
`news_id` int,
`title` string,
`platform` string,
`author` string,
`type` string,
`length` int,
`comment_num` int,
`publish_time` string,
`img_url` string,
`doc_url` string
)
PARTITIONED BY (`dt` string) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ods/ods_news_info_full';