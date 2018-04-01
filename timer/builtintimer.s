.include "../m328Pdef.inc"

.org 0000	; can start at end because we don't need interrupts
sbi DDRC, 0	; set PORTC to ouput
ldi r20, 0b00000101	; set timer prescaler to 1024
out TCCR0B, r20		; TCCR0B is the control register for timer 0

;--------------;
; MAIN ROUTINE ;
;--------------;
main_loop:
	sbi PINC, 0	; Toggle 0 bit
	rcall pause	; go to first pause
	rjmp main_loop

;----------------;
; PAUSE ROUTINES ;
;----------------;
pause:
plupe:	in r20, TIFR0	; TIFR0 is timer 0 interrupt flag register
	andi r20, 0b00000010	; check if timer is done
	breq plupe
	ldi r20, 0b00000010	; reset flag by writing 1 to it
	out TIFR0, r20
	ret
