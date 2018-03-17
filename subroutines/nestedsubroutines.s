.include "../m328Pdef.inc"

setup:
; Stack pointer initialization
LDI    R16,  low(RAMEND)  ; Load the lower 8 bits of the final address in RAM
OUT    SPL,  R16		  ; Store the lower 8 bits of the final adress in RAM
						  ; in the low register of the stack pointer
LDI    R16,  high(RAMEND) ; Load the upper 8 bits of the final address in RAM
OUT    SPH,  R16		  ; Store the upper 8 bits of the final address in RAM
						  ; in the high register o fthe stack pointer

; Output port initialization
LDI    R16,  0xFF         ; Load 0b11111111 in R16
OUT    DDRC, R16          ; Configure all pins on PortC as output

; Initializing values that we will recover from the stack
LDI    R16,  0b00101000
LDI    R17,  0b00010000

call SUBROUTINE

LOOP:
OUT    PORTC, R17		  ; Check if the output on the chip is right!
rjmp   LOOP				  ; Infinite loop


SUBROUTINE:
call NESTEDSUBROUTINE
push   R16
push   R17

LDI    R16,  0b11111111 ; Loading garbage into R16 and R17
LDI    R17,  0b11111111

pop    R17              ; Recovering original values
pop    R16
ret

NESTEDSUBROUTINE:
push   R16
push   R17

LDI    R16,  0b00000000 ; Loading garbage into R16 and R17
LDI    R17,  0b00000000

pop    R17              ; Recovering original values
pop    R16
ret