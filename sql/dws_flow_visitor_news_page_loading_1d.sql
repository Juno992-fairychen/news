drop  table  if  exists  dws_flow_visitor_news_page_loading_1d;
CREATE  EXTERNAL  TABLE  dws_flow_visitor_news_page_loading_1d(
`mid` string,
`os` string,
`brand` string,
`model` string,
`network` string,
`news_id` int,
`entrance` string,
`avg_load_time_1d` double,
`max_load_time_1d` double,
`min_load_time_1d` double
)
PARTITIONED BY (`dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '@'
stored as textfile
location '/user/hive/warehouse/news.db/dws/dws_flow_visitor_news_page_loading_1d';