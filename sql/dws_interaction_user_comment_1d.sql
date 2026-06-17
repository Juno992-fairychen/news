drop  table  if  exists  dws_interaction_user_comment_1d;
CREATE  EXTERNAL  TABLE  dws_interaction_user_comment_1d(
 `user_id` int,
 `gender` int,
 `age` int,
 `city` string,
 `device_type` string,
 `active` int,
 `comment_add_count_1d` BIGINT
 )
 PARTITIONED BY (`dt` string)
 ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
 stored as textfile
 location '/user/hive/warehouse/news.db/dws/dws_interaction_user_comment_1d';