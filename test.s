.include "m328Pdef.inc"

LDI    R16,  0xFF       ; Load 0b11111111 in R16
OUT    DDRC, R16        ; Configure all pins on PortC as output

LDI    R16,  0xFF       ; Load 0b11111111 in R16
OUT    PORTC, R16       ; Write all 1's to the pins of PortC