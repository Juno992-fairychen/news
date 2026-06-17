DROP TABLE IF EXISTS ads_user_view_count_top3_by_gender;
CREATE EXTERNAL TABLE ads_user_view_count_top3_by_gender(
    `gender` int,
    `news_id` int,
    `title` string,
    `platform` string,
    `author` string,
    `type` string,
    `view_count` bigint,
    `rank` bigint
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ads/ads_user_view_count_top3_by_gender'; 