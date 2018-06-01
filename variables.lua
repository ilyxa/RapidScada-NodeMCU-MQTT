wifi_signal_mode = wifi.PHYMODE_N
time_between_sensor_readings_rtcmem_flag = rtcmem.read32(1) -- flag
time_between_sensor_readings_rtcmem_value = rtcmem.read32(2) -- value
if  time_between_sensor_readings_rtcmem_flag == 1 then -- 1 per-device
    time_between_sensor_readings = time_between_sensor_readings_rtcmem_value * 1000
else -- use default 60 seconds interval
    time_between_sensor_readings = 60000
end
update_interval_hard_limit_high = 600 -- seconds prevent wrong value reading from scada - 10 minutes
update_interval_hard_limit_low = 5 
mqtt_keepalive = time_between_sensor_readings_rtcmem_value + 30
heartbeat = 0
online_status = 1 -- 1 - offline 2 - online 3 - sensor error
temperature = 0
humidity = 0
voltage = 0
rssi = 0
mac = 0
connected = false
