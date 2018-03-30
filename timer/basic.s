.include "../m328Pdef.inc"

.org 0000	; can start at end because we don't need interrupts
sbi DDRC, 0	; set PORTC to ouput

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
pause:	ldi r16, 0	; set up our counter
plupe:	rcall mpause	; call another delay loop
	dec r16		; decrement our counter
	brne plupe	; check to see if we're back down to zero
			; if not, continue looping
	ret
mpause: ldi r17, 0	; set up another counter
mplup:	dec r17		; decrement counter
	brne mplup	; loop til we hit zero
	ret
