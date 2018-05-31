sudo 7zr x -y scada-data.7z
sudo chown -R scada:scada /opt/scada
sudo chmod -R ugo+rwx /opt/scada/ScadaWeb/config
sudo chmod -R ugo+rwx /opt/scada/ScadaWeb/log
sudo chmod -R ugo+rwx /opt/scada/ScadaWeb/storage
./scadarestart.sh
