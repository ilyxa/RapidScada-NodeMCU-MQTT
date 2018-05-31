#!/bin/sh
/usr/bin/mosquitto_pub -h scada -q 1 -r -t heartbeat -m $(printf "%d" 0x$(openssl rand -hex $(( 2 ))))
