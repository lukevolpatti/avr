.include "../m328Pdef.inc"

jmp setup
.org INT0addr ; INT0addr is the address of EXT_INT0
jmp handle_pb0

setup:
; Stack pointer initialization
LDI    R16,  low(RAMEND)  ; Load the lower 8 bits of the final address in RAM
OUT    SPL,  R16		  ; Store the lower 8 bits of the final adress in RAM
						  ; in the low register of the stack pointer
LDI    R16,  high(RAMEND) ; Load the upper 8 bits of the final address in RAM
OUT    SPH,  R16		  ; Store the upper 8 bits of the final address in RAM
						  ; in the high register o fthe stack pointer

LDI    R16,  0xFF       ; Load 0b11111111 in R16
OUT    DDRC, R16        ; Configure all pins on PortC as output

LDI    R16,  0x00       ; Load 0b00000000 in R16
OUT    PORTC, R16       ; Write all 0's to the pins of PortC

LDI	   R16,  0x80		; Load 0b10000000 in R16
;OUT    SREG, R16		; Enable interrupts in SREG
sei

LDI    R16,  0xFF		; Load 0b11111111 in R16
;OUT    EICRA,R16		; Now any logical change to pin triggers interrupt
;OUT    EIMSK,R16		; Enable interrupts requests.
ldi R16, (1 << ISC11) | (1 << ISC01)
sts EICRA, R16
in R16, EIMSK 
ori R16, (1<<INT0) | (1<<INT1)
out EIMSK, R16

LOOP:
RJMP LOOP

handle_pb0:
IN     R16, PortC       ; Get values from PortC
LDI	   R17, 0xFF		; Load 0b11111111 in R17
EOR    R16, R17			; XOR R16 with R17 and store in R16
OUT    PORTC,R16		; Write result to PortC.

RETI