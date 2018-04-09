.include "../m328Pdef.inc"

LDI    R16,  0xFF       ; Load 0b11111111 in R16
OUT    DDRB, R16        ; Configure all pins on PortB as output

LDI    R16,  0b01000100
OUT    PORTB, R16       ; Write 1's to two pins of PortB
