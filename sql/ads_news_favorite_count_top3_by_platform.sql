drop  table  if  exists  ads_news_favorite_count_top3_by_platform;
CREATE EXTERNAL  TABLE  ads_news_favorite_count_top3_by_platform(
`dt` string,
`platform` string,
`news_id` int,
`title` string,
`author` string,
`favorite_count` bigint,
`rank` bigint
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/ads/ads_news_favorite_count_top3_by_platform';