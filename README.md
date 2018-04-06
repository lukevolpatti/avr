# avr
A repository of AVR code examples.
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

To do: motor control, IR sensors, possibly button control.
