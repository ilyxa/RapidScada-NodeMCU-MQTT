del scada-data.7z
"c:\Program Files\7-Zip\7z.exe" a -x!ScadaServer\Config\ScadaServerSvcConfig.xml* -x!ScadaServer\Config\ModAutoControl.xml scada-data.7z BaseDAT Interface ScadaComm\Config ScadaServer\Config  ScadaWeb\config ScadaComm\KP\KpMQTT.dll
"c:\Program Files\PuTTY\pscp.exe" -noagent -pw scada scada-data.7z scada@scada:/opt/scada