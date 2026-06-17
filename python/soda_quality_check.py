import sys
import requests
import pandas as pd
from soda.scan import Scan

dt = "2026-05-01"
print(f"启动数据质量检查 - 日期: {dt}")

# ============================================================
# 1. Trino HTTP 查询函数
# ============================================================
def query_trino(sql):
    url = "http://hadoop2428:8080/v1/statement"
    headers = {
        "X-Trino-User": "juno",
        "X-Trino-Catalog": "hive",
        "X-Trino-Schema": "news"
    }
    resp = requests.post(url, headers=headers, data=sql)
    if resp.status_code != 200:
        raise Exception(f"Trino 提交失败: {resp.text}")
    result = resp.json()
    data_rows = []
    next_uri = result.get("nextUri")
    while next_uri:
        page_resp = requests.get(next_uri, headers=headers)
        page_data = page_resp.json()
        if "data" in page_data:
            data_rows.extend(page_data["data"])
        if "error" in page_data:
            raise Exception(f"查询错误: {page_data['error']['message']}")
        next_uri = page_data.get("nextUri")
    return data_rows

# ============================================================
# 2. 数据抽取
# ============================================================
print("正在从 Trino 抽取数据...")
ods_data = query_trino(f"""
    SELECT id, base, event_list 
    FROM ods_event_log_inc 
    WHERE dt = '{dt}' 
    LIMIT 20000
""")
print(f"  ODS 层: {len(ods_data)} 行")

dwd_data = query_trino(f"""
    SELECT news_id, uid, mid 
    FROM dwd_flow_click_inc 
    WHERE dt = '{dt}' 
    LIMIT 20000
""")
print(f"  DWD 层: {len(dwd_data)} 行")

# ============================================================
# 3. 转 Pandas DataFrame
# ============================================================
ods_df = pd.DataFrame(ods_data, columns=['id', 'base', 'event_list'])
dwd_df = pd.DataFrame(dwd_data, columns=['news_id', 'uid', 'mid'])

# ============================================================
# 4. Soda 扫描（数据源名称统一为 soda_pandas）
# ============================================================
DATA_SOURCE_NAME = "soda_pandas"

scan = Scan()
scan.set_data_source_name(DATA_SOURCE_NAME)

# 显式传入 data_source_name，消除警告
scan.add_pandas_dataframe(
    dataset_name="ods_event_log_inc",
    pandas_df=ods_df,
    data_source_name=DATA_SOURCE_NAME
)
scan.add_pandas_dataframe(
    dataset_name="dwd_flow_click_inc",
    pandas_df=dwd_df,
    data_source_name=DATA_SOURCE_NAME
)

# ============================================================
# 5. SodaCL 校验规则
# ============================================================
sodacl_checks = """
checks for ods_event_log_inc:
  - row_count > 0
  - missing_count(id) = 0

checks for dwd_flow_click_inc:
  - row_count > 0
  - missing_count(news_id) = 0
  
  - row_count:
      name: 热点新闻20000126点击量
      filter: news_id = '20000126'
      fail: when < 50
      warn: when < 80
"""

scan.add_sodacl_yaml_str(sodacl_checks)
scan.execute()

# ============================================================
# 6. 输出结果
# ============================================================
print("\n" + "="*50)
print("数据质量检查报告")
print("="*50)
print(scan.get_logs_text())

if scan.has_check_fails():
    print("数据质量检查失败！")
    sys.exit(1)
else:
    print("所有检查通过！")
