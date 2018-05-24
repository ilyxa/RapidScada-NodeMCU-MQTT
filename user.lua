dofile("credentials.lua")
wifi_signal_mode = wifi.PHYMODE_G
time_between_sensor_readings = 5000
heartbeat = 0
m = mqtt.Client(mqtt_client_id, 15, mqtt_username, mqtt_password, 1)
m:lwt("esp1/online", 1, 0, 0)
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
end)
temperature = 0
humidity = 0
voltage = 0
connected = false
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi_signal_mode)
wifi.sta.config {ssid=wifi_SSID, pwd=wifi_password}
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
end
function get_sensor_Data()
    status, temp, humi, temp_dec, humi_dec = dht.read(5)
    if status == dht.OK then
        --print("Temperature: "..(temp).."."..(temp % 10).." deg C")
        --print("Humidity: "..(humi).."."..(humi % 10).."%")
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end

function loop()
    if wifi.sta.status() == 5 then
        tmr.stop(0)
        print("Connecting to MQTT...")
        m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(client)
             get_sensor_Data()
             voltage = adc.readvdd33() / 1000
             m:subscribe("heartbeat", 0, function() end)
             m:publish((mqtt_client_id).."/temperature",(temp).."."..(temp % 10), 0, 0, function()
             m:publish((mqtt_client_id).."/humidity",(humi).."."..(humi % 10), 0, 0, function()
             m:publish((mqtt_client_id).."/voltage",(voltage).."."..(voltage % 100), 0, 0, function()
             m:publish((mqtt_client_id).."/heartbeat",heartbeat, 0, 0, function()
             m:publish((mqtt_client_id).."/online", 2, 0, 0, function()
                 node.dsleep(time_between_sensor_readings*1000)
             end) end) end) end) end)
        end,
        function(client, reason)
            print("error: "..reason)
            node.restart()
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
