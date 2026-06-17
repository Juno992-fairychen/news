DROP TABLE IF EXISTS ads_flow_click_count_by_action;
CREATE EXTERNAL TABLE ads_flow_click_count_by_action(
    `action` string,
    `click_count` bigint
)
PARTITIONED BY (`dt` string) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ads/ads_flow_click_count_by_action';