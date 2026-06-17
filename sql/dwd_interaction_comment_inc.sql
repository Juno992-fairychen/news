DROP TABLE IF EXISTS dwd_interaction_comment_inc;

CREATE EXTERNAL TABLE dwd_interaction_comment_inc (
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
    user_id STRING,
    news_id STRING,
    content STRING,
    add_time STRING,
    like_num INT,
    reply_num INT,
    stay_time STRING,
    event_time STRING
)
PARTITIONED BY (dt STRING)
STORED AS ORC
LOCATION '/user/hive/warehouse/news.db/dwd/dwd_interaction_comment_inc'
TBLPROPERTIES ("orc.compress"="SNAPPY");