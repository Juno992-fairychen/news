DROP TABLE ods_event_log_inc;
CREATE EXTERNAL TABLE ods_event_log_inc(id string,base string,event_list string PARTITIONED BY(dt string) STORED AS textfile;