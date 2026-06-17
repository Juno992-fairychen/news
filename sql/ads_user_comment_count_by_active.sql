DROP TABLE IF EXISTS ads_user_comment_count_by_active;
CREATE EXTERNAL TABLE ads_user_comment_count_by_active (
    `active` int COMMENT '是否活跃（0-否，1-是）',
    `comment_count` bigint COMMENT '评论总数'
)
COMMENT '每日活跃与非活跃用户评论数统计大屏表'
PARTITIONED BY (`dt` string COMMENT '统计日期') 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ads/ads_user_comment_count_by_active';
