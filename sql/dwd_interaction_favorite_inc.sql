DROP TABLE IF EXISTS dwd_interaction_favorite_inc;

CREATE EXTERNAL TABLE dwd_interaction_favorite_inc (
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
    news_id STRING,
    user_id STRING,
    add_time STRING,
    stay_time STRING,
    event_time STRING
)
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/user/hive/warehouse/news.db/dwd/dwd_interaction_favorite_inc'
TBLPROPERTIES ("orc.compress"="SNAPPY");