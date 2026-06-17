use  news;
drop table if exists `dim_date_info`;
CREATE EXTERNAL TABLE `dim_date_info` (
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
LOCATION '/user/hive/warehouse/news.db/dim/dim_date_info';