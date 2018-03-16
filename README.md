# avr
## Compiling
### Using avra
~~~~
. avra myFile.s
~~~~

## Loading
### ATmega329P
~~~~
. avrdude -c usbtiny -p atmega328p -U flash:w:myFile.s.hex
~~~~
