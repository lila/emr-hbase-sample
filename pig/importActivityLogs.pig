register /home/hadoop/lib/hbase-0.90.3.jar;

 raw_data = LOAD '$reads' USING PigStorage( ',' ) AS (
row_id: chararray,
service_id: chararray,
source_id: chararray, 
agent_id: chararray,
device_id: chararray,
event_id: chararray,
page_id: chararray,
user_profile_id: chararray,
content_id: chararray,
date_id: chararray,
millis: chararray,
channel_id: chararray,
byte_size: chararray,
elapsed_millis: chararray,
session_id: chararray,
country_code: chararray,
ip_address: chararray,
imei: chararray,
music_pc_client: chararray,
status: chararray,
external_id: chararray,
campaign_id: chararray,
location_id: chararray,
prop_20: chararray,
session_num: chararray,
session_page_num: chararray
);

STORE raw_data INTO 'hbase://activity_logs' USING
 org.apache.pig.backend.hadoop.hbase.HBaseStorage (
   'info:service_id info:source_id info:agent_id info:device_id info:event_id info:page_id info:user_profile_id info:content_id info:date_id info:millis info:channel_id info:byte_size info:elapsed_millis info:session_id info:country_code info:ip_address info:imei info:music_pc_client info:status info:external_id info:campaign_id info:location_id info:prop_20 info:session_num info:session_page_num');

