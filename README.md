![screenshot](https://raw.githubusercontent.com/ilyxa/NodeMCU_dht22_MQTT_DeepSleep/master/rapidscada_demo_screenshot.jpg "RapidScada Table Screenshot")

### Software

RapidScada, free and easy to use SCADA system https://rapidscada.org

KpMQTT.dll https://github.com/bersim/OpenKPs/tree/master/KpMQTT

Eclipse Mosquitto https://github.com/eclipse/mosquitto

Works ONLY with Mosquitto (no idea why, RabbitMQ was a huge problem)

### ESP8266 Setup

```
cp credentials.lua.example credentials.lua
```
edit credentials.lua any way
upload: 
```
luatool.py -f init.lua
luatool.py -f user.lua
luatool.py -f credentials.lua
```

crontab entry
```
* * * * *       /opt/scada/regenerate_heartbeat.sh
```

Heartbeat logic: every minutes topic "heartbeat" pub new value generated randomly. Every session from ESP sensors network get new system value and re-publish it again and again to make sure that sensor is online and health state is OK. 

### TODO
*xor values temp and humi w/ current heartbeat values.
*RapidScada setup.
