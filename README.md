![screenshot](https://raw.githubusercontent.com/ilyxa/NodeMCU_dht22_MQTT_DeepSleep/master/rapidscada_demo_screenshot.jpg "RapidScada Table Screenshot")

RapidScada, free and easy to use SCADA system https://rapidscada.org

KpMQTT.dll https://github.com/bersim/OpenKPs/tree/master/KpMQTT

Eclipse Mosquitto https://github.com/eclipse/mosquitto

Works ONLY with Mosquitto (no idea why, RabbitMQ was a huge problem)

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
