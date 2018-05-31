#!/bin/sh
set -x
/bin/cp /opt/scada/ScadaComm/Log/line001.log /opt/scada/ScadaComm/Log/line001.log.$(/bin/date +%Y%m%d%H%M).dump
cat /dev/null > /opt/scada/ScadaComm/Log/line001.log
sudo service scadacomm restart 
