# Cartes
Carte 8 = envois données  
Carte 12 = réception de données

# Commandes utiles

minicom -ow -D /dev/ttyUSBX  
lpcprog -d /dev/ttyUSBX -c id  
lpcprog -d /dev/ttyUSBX -c flash [program.bin]  

# Envois des données de python vers le mircrocontroleur

Le programme python envois ```(X,Y,intensité)``` à la carte.

# Envois de python vers le SRV WEB

https://emergencymanager.azurewebsites.net/fire/send  
https://cpefiresimulation.azurewebsites.net/get
