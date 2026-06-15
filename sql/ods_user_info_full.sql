drop table if exists ods_user_info_full;
CREATE EXTERNAL TABLE ods_user_info_full (
`user_id` int,
`user_name` string,
`gender` int,
`age` int,
`phone` string,
`province` string,
`city` string,
`device_type` string,
`active` int,
`modify_date` string,
`create_date` string
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ods/ods_user_info_full';