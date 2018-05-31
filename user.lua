dofile("credentials.lua")
wifi_signal_mode = wifi.PHYMODE_N
time_between_sensor_readings = 60000
update_interval_hard_limit = 300 -- seconds
heartbeat = 0
online_status = 1 -- 1 - offline 2 - online 3 - sensor error
temperature = 0
humidity = 0
voltage = 0
rssi = 0
mac = 0
connected = false
dht_pin = 5 -- esp-01 = 4 esp-12 = 5

mac = wifi.sta.getmac()
mqtt_client_id = mqtt_client_id .. mac:gsub(":","")

m = mqtt.Client(mqtt_client_id, 90, mqtt_username, mqtt_password, 1)
m:lwt((mqtt_client_id).."/online", 1, 0, 0) -- offline event
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
      if data ~= nil then
          if tonumber(data) <= update_interval_hard_limit then -- 5 minutes limit (check in scada)
              time_between_sensor_readings = tonumber(data) * 1000
              --print(time_between_sensor_readings)
              --print(tonumber(data)*1000)
          end
      end
  elseif (topic == "update_interval") then
      if data ~= nil then
          if tonumber(data) <= update_interval_hard_limit then
              time_between_sensor_readings = tonumber(data) * 1000
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
             m:publish((mqtt_client_id).."/update_interval",time_between_sensor_readings/1000,0,0,function()
             m:publish((mqtt_client_id).."/voltage",voltage, 0, 0, function()
             m:publish((mqtt_client_id).."/rssi",rssi, 0, 0, function()
             m:publish((mqtt_client_id).."/heartbeat",heartbeat, 0, 0, function()
             m:publish((mqtt_client_id).."/online", online_status, 0, 0, function()
                node.dsleep(time_between_sensor_readings*1000,1)
             end) end) end) end) end) end) end)
        end,
        function(client, reason)
            print("error: "..reason)
            node.dsleep(time_between_sensor_readings*1000,1)
            node.restart() -- no exeption handling just reboot-and-forget, in worst case it takes too much power
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
