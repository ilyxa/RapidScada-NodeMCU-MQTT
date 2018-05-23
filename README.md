RapidScada, free and easy to use SCADA system https://rapidscada.org

KpMQTT.dll https://github.com/bersim/OpenKPs/tree/master/KpMQTT
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


