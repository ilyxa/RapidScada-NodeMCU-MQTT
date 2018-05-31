dofile("credentials.lua")
wifi_signal_mode = wifi.PHYMODE_N
local temp_rtc_1 = rtcmem.read32(1) -- flag
local temp_rtc_2 = rtcmem.read32(2) -- value
if temp_rtc_1 == 99 then -- 99 is "magic" later 48879 0xbeef
    time_between_sensor_readings = temp_rtc_2 * 1000
else
    time_between_sensor_readings = 60000
end
update_interval_hard_limit_high = 300 -- seconds prevent wrong value reading from scada
update_interval_hard_limit_low = 5 
mqtt_keepalive = time_between_sensor_readings / 1000 + 30 -- not work as expected check again
heartbeat = 0
online_status = 1 -- 1 - offline 2 - online 3 - sensor error
temperature = 0
humidity = 0
voltage = 0
rssi = 0
mac = 0
connected = false
enable_global_update = true
dht_pin = 5 -- esp-01 = 4 esp-12 = 5

mac = wifi.sta.getmac()
mqtt_client_id = mqtt_client_id .. mac:gsub(":","")

m = mqtt.Client(mqtt_client_id, mqtt_keepalive, mqtt_username, mqtt_password, 1) -- check dynamic keepalive settings
m:lwt((mqtt_client_id).."/online", 1, 0, 1) -- offline event
m:on("connect", function(client) print ("connected") end)
m:on("offline", function(client) 
    print ("offline") 
end)
m:on("message", function(client, topic, data)
  if (topic == "heartbeat") then
    if data ~= nil then
        heartbeat = data
    end
  end
  if (topic == (mqtt_client_id).."/update_interval") then
  --if (topic == "update_interval") then
      if data ~= nil then -- TODO add temp and checking zero and below value
          data_temp = tonumber(data)
          if data_temp > update_interval_hard_limit_low and data_temp <= update_interval_hard_limit_high then --hardlimit
              time_between_sensor_readings = data_temp * 1000
              mqtt_keepalive = data_temp + 30
              enable_global_update = false
              rtcmem.write32(1,99)
              rtcmem.write32(2,data_temp)
              --print(time_between_sensor_readings)
              --print(tonumber(data)*1000)
          else
              enable_global_update = true
          end
      end
  end
  if (topic == "update_interval" and enable_global_update) then
      if data ~= nil then
          data_temp = tonumber(data)
          if data_temp > update_interval_hard_limit_low and data_temp <= update_interval_hard_limit_high then --hardlimit
              time_between_sensor_readings = data_temp * 1000
              mqtt_keepalive = data_temp + 30
              rtcmem.write32(1,99)
              rtcmem.write32(2,data_temp)
          else
              --print("do nothing stay on default value")
          end
      end
  end
end)

wifi.setmode(wifi.STATION)
wifi.setphymode(wifi_signal_mode)
wifi.sta.config {ssid=wifi_SSID, pwd=wifi_password}
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
end
function get_sensor_Data()
    status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
    if status == dht.OK then
        --print("Temperature: "..(temp).."."..(temp % 10).." deg C")
        --print("Humidity: "..(humi).."."..(humi % 10).."%")
        online_status = 2
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
        online_status = 3
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
        online_status = 3
    end
end

function loop()
    if wifi.sta.status() == 5 then
        tmr.stop(0)
--        print("Connecting to MQTT...")
        m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(client)
             get_sensor_Data()
             voltage = adc.readvdd33()
             rssi = wifi.sta.getrssi()

             m:subscribe({["heartbeat"]=0,["update_interval"]=0,[(mqtt_client_id).."/update_interval"]=0}, 0, function() end)
             m:publish((mqtt_client_id).."/temperature",temp, 0, 0, function()
             m:publish((mqtt_client_id).."/humidity",humi, 0, 0, function()
             m:publish((mqtt_client_id).."/update_interval",time_between_sensor_readings/1000,0,1,function()
             m:publish((mqtt_client_id).."/voltage",voltage, 0, 0, function()
             m:publish((mqtt_client_id).."/rssi",rssi, 0, 0, function()
             m:publish((mqtt_client_id).."/heartbeat",heartbeat, 0, 0, function()
             m:publish((mqtt_client_id).."/online", online_status, 0, 1, function()
                node.dsleep(time_between_sensor_readings*1000,1)
             end) end) end) end) end) end) end)
        end,
        function(client, reason)
            print("error: "..reason)
            node.dsleep(time_between_sensor_readings*1000,1)
--            node.restart() -- no exeption handling just reboot-and-forget, in worst case it takes too much power
        end)
        
    else
        print("Connecting...")
--        print(wifi.sta.status())
    end
end

if adc.force_init_mode(adc.INIT_VDD33)
    then
        node.restart()
        return
    end

tmr.alarm(0, 100, 1, function() loop() end)
