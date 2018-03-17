-- MQTT connect script with deep sleep
-- Remember to connect GPIO16 and RST to enable deep sleep

--############
--# Settings #
--############
dofile("credentials.lua")
-- wifi.PHYMODE_B 802.11b, More range, Low Transfer rate, More current draw
-- wifi.PHYMODE_G 802.11g, Medium range, Medium transfer rate, Medium current draw
-- wifi.PHYMODE_N 802.11n, Least range, Fast transfer rate, Least current draw
wifi_signal_mode = wifi.PHYMODE_G
-- If the settings below are filled out then the module connects
-- using a static ip address which is faster than DHCP and
-- better for battery life. Blank "" will use DHCP.
-- My own tests show around 1-2 seconds with static ip
-- and 4+ seconds for DHCP
client_ip=""
client_netmask=""
client_gateway=""

--- INTERVAL ---
-- In milliseconds. Remember that the sensor reading,
-- reboot and wifi reconnect takes a few seconds
time_between_sensor_readings = 10000

--################
--# END settings #
--################

-- Setup MQTT client and events
m = mqtt.Client(mqtt_client_id, 120, mqtt_username, mqtt_password)
temperature = 0
humidity = 0

-- Connect to the wifi network
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi_signal_mode)
wifi.sta.config {ssid=wifi_SSID, pwd=wifi_password}
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
end

-- DHT22 sensor logic
function get_sensor_Data()
    status, temp, humi, temp_dec, humi_dec = dht.read(5)
    if status == dht.OK then
        print("Temperature: "..(temp).."."..(temp % 10).." deg C")
        print("Humidity: "..(humi).."."..(humi % 10).."%")
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end

function loop()
    if wifi.sta.status() == 5 then
        -- Stop the loop
        tmr.stop(0)
        print("Connecting to MQTT...")
        m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(conn)
            print("Connected to MQTT")
            print("  IP: ".. mqtt_broker_ip)
            print("  Port: ".. mqtt_broker_port)
            print("  Client ID: ".. mqtt_client_id)
            print("  Username: ".. mqtt_username)
            -- Get sensor data
            get_sensor_Data()
            m:publish("esp1/temperature",(temp).."."..(temp % 10), 0, 0, function(conn)
                   m:publish("esp1/humidity",(humi).."."..(humi % 10), 0, 0, function(conn)
                    print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
                    node.dsleep(time_between_sensor_readings*1000)             
                end)          
            end)
        end )
    else
        print("Connecting...")
    end
end

tmr.alarm(0, 100, 1, function() loop() end)
