drop  table  if  exists  ads_news_like_count_top3_by_type;
CREATE  EXTERNAL  TABLE  ads_news_like_count_top3_by_type(
`dt` string,
`type` string,
`news_id` int,
`title` string,
`author` string,
`like_count` bigint,
`rank` bigint
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/ads/ads_news_like_count_top3_by_type';