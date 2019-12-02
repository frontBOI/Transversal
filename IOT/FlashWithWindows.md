# Comment flasher les microcontroleurs avec un PC Windows

## 1. Désactiver les ports séries de la VM.
![unable serial ports on VM](https://github.com/frontBOI/Transversal/blob/LeoBranch/IOT/img/unableSerialPort.PNG)

## 2. Lancer la VM
## 3. Brancher le microcontroleur sur un port USB
## 4. Activer le périphérique USB depuis VBox.
![Activate usb devices on VBox](https://github.com/frontBOI/Transversal/blob/LeoBranch/IOT/img/usb.PNG)
## 5. Vérifier sa présence dans ```/dev/``` avec un ```ls /dev/ | grep tty```
Si tout c'est bien passé un ```ttyUSBX``` est apparu. Vous pouvez désormais le flasher :)
