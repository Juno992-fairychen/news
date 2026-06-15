#!/bin/bash
# Hive安装目录
HIVE_HOME=/opt/module/hive-4.0.0

# 如果参数为空，dt默认为前一天的日期
if [ -n "$1" ] ;then
    dt=$1
else
    dt=`date -d "-1 day" +%F`
fi

# 核心安全防线：动态获取当前执行脚本（bin目录）的绝对路径
BIN_DIR=$(cd "$(dirname "$0")"; pwd)

# 逆向推导：根据bin目录的绝对路径，向上退一级再进入sql目录，锁定SQL文件的绝对路径
SQL_PATH="${BIN_DIR}/../sql/dwd_base_event_log_inc.sql"

# 使用 -f 执行指定路径下的 SQL 文件，并通过 --hiveconf 动态注入日期变量
$HIVE_HOME/bin/beeline -u "jdbc:hive2://hadoop2428:10000" -n juno --hiveconf dt="$dt" -f "$SQL_PATH"

