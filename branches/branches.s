.include "m328Pdef.inc"

setup:
LDI    R16,  0xFF       ; Load 0b11111111 in R16
OUT    DDRC, R16        ; Configure all pins on PortC as output
LDI    R16,  0x00		; Load 0 into R16
cp 	   R16,  R0			; Compare R16 to R0. Results will be stored in SREG.
breq   LIGHT			; Check to see if the previous operation was equal.

LOOP:
rjmp LOOP				; Infinite loop

LIGHT:
LDI    R16,  0xFF       ; Load 0b11111111 in R16
OUT    PORTC, R16       ; Write all 1's to the pins of PortC
rjmp LOOP