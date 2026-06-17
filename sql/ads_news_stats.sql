DROP TABLE IF EXISTS ads_news_stats;
CREATE EXTERNAL TABLE ads_news_stats(
    `like_count` bigint,
    `favorite_count` bigint,
    `repost_count` bigint
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ads/ads_news_stats';