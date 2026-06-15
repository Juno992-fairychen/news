USE news;

INSERT OVERWRITE TABLE dwd_base_event_log_inc PARTITION(dt='${hiveconf:dt}') 
SELECT 
    get_json_object(base,'$.mid') mid,
    get_json_object(base,'$.uid') uid,
    get_json_object(base,'$.vc') vc,
    get_json_object(base,'$.vn') vn,
    get_json_object(base,'$.lan') lan,
    get_json_object(base,'$.source') source,
    get_json_object(base,'$.os') os,
    get_json_object(base,'$.area') area,
    get_json_object(base,'$.model') model,
    get_json_object(base,'$.brand') brand,
    get_json_object(base,'$.resolution') resolution,
    get_json_object(base,'$.t') app_time,
    get_json_object(base,'$.network') network,
    get_json_object(base,'$.lon') lon,
    get_json_object(base,'$.lat') lat,
    get_json_object(event,'$.event_name') event_name,
    get_json_object(event,'$.event_body') event_json,
    get_json_object(event,'$.event_time') event_time
FROM
(
    SELECT
        tmpinner.id,
        tmpinner.base,
        events.event
    FROM
    (
        SELECT
            id,
            base,
            REPLACE(regexp_extract(event_list,'^\\[(.+)\\]$',1), '},{\"event_body\"', '}||{\"event_body\"') AS event_list
        FROM news.ods_event_log_inc 
        WHERE dt='${hiveconf:dt}'
    ) tmpinner 
    LATERAL VIEW OUTER explode(split(event_list,'\\|\\|')) events AS event
) tmpouter;
