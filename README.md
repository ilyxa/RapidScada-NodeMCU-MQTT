![screenshot](https://raw.githubusercontent.com/ilyxa/NodeMCU_dht22_MQTT_DeepSleep/master/misc/rapidscada_demo_screenshot.jpg "RapidScada Table Screenshot")

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

[scripts/](scripts/) script running on RapidScada Site and development VM
* [scripts/cleanup.sh](scripts/cleanup.sh) Cleanup all logs in Rapidscada installation
* [scripts/package.cmd](scripts/package.cmd) repack config on DevVM RapidScada Windows and send it to prodsite
* [scripts/regenerate_heartbeat.sh](scripts/regenerate_heartbeat.sh) Regenerate system heartbeat (every * minutes)
* [scripts/restart_scadacomm.sh](scripts/restart_scadacomm.sh) Dump current log file and restart ScadaComm (for monit)
* [scripts/update_config.sh](scripts/update_config.sh) Unpack archive from package.cmd and restart RapidScada

[esp_firmware/](esp_firmware/) NodeMCU Sensor 2.2.0 with modules ADC BIT BME280 DHT DS18B20 FILE GPIO I2C MQTT NET NODE OW RTCMEM SPI TLS TMR UART WIFI

[dlls/](dlls/) KpMQTT.dll with Retain support

### ESP8266 Setup

Prepare firmware:
* use my version [esp_firmware/](esp_firmware/)
* use [https://nodemcu-build.com](https://nodemcu-build.com)
* use hard (not so) way to build your own, [manual here](https://nodemcu.readthedocs.io/en/master/en/build/)

Update firmware, [manual and details is here](https://nodemcu.readthedocs.io/en/master/en/flash/).

```
esptool write_flash 0x00000 0x00000.bin 0x10000 0x10000.bin
```

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
