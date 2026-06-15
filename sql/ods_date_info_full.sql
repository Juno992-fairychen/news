drop table if exists `ods_date_info_full`;
CREATE EXTERNAL TABLE `ods_date_info_full` (
`date_id` int,
`week_id` string,
`week_day` string,
`day` string,
`month` string,
`quarter` int,
`year` int,
`is_workday` string,
`holiday_id` string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
STORED AS textfile
LOCATION '/user/hive/warehouse/news.db/ods/ods_date_info_full';