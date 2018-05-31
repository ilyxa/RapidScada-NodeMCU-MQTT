![screenshot](https://raw.githubusercontent.com/ilyxa/NodeMCU_dht22_MQTT_DeepSleep/master/rapidscada_demo_screenshot.jpg "RapidScada Table Screenshot")

### Software

RapidScada, free and easy to use SCADA system https://rapidscada.org

KpMQTT.dll https://github.com/bersim/OpenKPs/tree/master/KpMQTT

Eclipse Mosquitto https://github.com/eclipse/mosquitto

Works **ONLY** with Mosquitto (no idea why, RabbitMQ was a huge problem)

### Files structure:
[conf/](conf/) config examples
* [conf/KpMQTT_scada.xml](conf/KpMQTT_scada.xml) KpMQTT config example
* [conf/incnl.dat](conf/incnl.dat) Input Channel Config file for RapidScada
* [conf/scada.conf.apache](conf/scada.conf.apache) Example config for Apache 2.2 + mod_mono
### ESP8266 Setup

```
cp credentials.lua.example credentials.lua
```
Edit credentials.lua any way

Upload: 
```
luatool.py -f init.lua
luatool.py -f user.lua
luatool.py -f credentials.lua
```

### RapidScada setup
**TODO**

### Heartbeat
crontab entry
```
* * * * *       /opt/scada/regenerate_heartbeat.sh
```

Heartbeat logic: every minutes topic "heartbeat" pub new value generated randomly. Every session from ESP sensors network get new system value and re-publish it again and again to make sure that sensor is online and health state is OK. 

### TODO
* xor values temp and humi w/ current heartbeat values.
* RapidScada setup.
