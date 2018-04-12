# avr
A repository of AVR code examples. Includes code for an autonomous LEGO car. 
## Compiling
### Using avra
~~~~
avra myFile.s
~~~~

## Loading
### ATmega328P
~~~~
avrdude -c usbtiny -p atmega328p -U flash:w:myFile.s.hex
~~~~
