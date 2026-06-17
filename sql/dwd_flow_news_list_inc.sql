DROP TABLE IF EXISTS dwd_flow_news_list_inc;

CREATE EXTERNAL TABLE dwd_flow_news_list_inc (
    mid STRING,
    uid INT,
    vc STRING,
    vn STRING,
    lan STRING,
    source STRING,
    os STRING,
    area STRING,
    model STRING,
    brand STRING,
    resolution STRING,
    app_time STRING,
    network STRING,
    lon STRING,
    lat STRING,
    action STRING,
    load_time STRING,
    load_way STRING,
    load_type STRING,
    ecc STRING,
    event_time STRING
)
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/user/hive/warehouse/news.db/dwd/dwd_flow_news_list_inc'
TBLPROPERTIES ("orc.compress"="SNAPPY");