DROP TABLE IF EXISTS ads_flow_avg_max_min_loading_time;

CREATE EXTERNAL TABLE ads_flow_avg_max_min_loading_time(
    `avg_load_time` decimal(10,1), 
    `max_load_time` bigint,
    `min_load_time` bigint
)
PARTITIONED BY (`dt` string) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ads/ads_flow_avg_max_min_loading_time';