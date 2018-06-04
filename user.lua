dofile("credentials.lua")
dofile("device_vars.lua")
dofile("variables.lua")

mac = wifi.sta.getmac()
mqtt_client_id = board_id .. mac:gsub(":","")

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
      if data ~= nil then -- TODO add temp and checking zero and below value
          local data_temp = tonumber(data)
          if data_temp >= update_interval_hard_limit_low 
              and data_temp <= update_interval_hard_limit_high then
                time_between_sensor_readings = data_temp * 1000
                mqtt_keepalive = data_temp + 30
                rtcmem.write32(1,1) -- per-device
                rtcmem.write32(2,data_temp)
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
    local dht_pin = 5
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
            print(".")
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
                 print(".")
                node.dsleep(time_between_sensor_readings*1000,1)
             end) end) end) end) end) end) end)
        end,
        function(client, reason)
            print("error: "..reason)
            node.dsleep(time_between_sensor_readings*1000,1)
        end)
        
    else
--        print("Connecting...")
--        print(wifi.sta.status())
    end
end

if adc.force_init_mode(adc.INIT_VDD33)
    then
        node.restart()
        return
    end

tmr.alarm(0, 100, 1, function() loop() end)
