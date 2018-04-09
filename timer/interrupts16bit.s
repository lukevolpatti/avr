.include "../m328Pdef.inc"

jmp reset

; This is where to go when the timer overflow interrupts
.org 0x001A
jmp timerOverflowISR


reset:	; Stack initialization:
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	; Setting inputs and outputs
	sbi DDRC, 0	; Set PORTC0 to output
	
	; Setting timer
	ldi r16, 0b00000010	; Set timer prescaler to 8
	sts TCCR1B, r16
	
	; Enabling timer's interrupts:
	ldi r16, 0b00000001
	sts TIMSK1, r16

	; Globally enabling interrupts:
	sei

; Main loop, in which we do nothing but wait for interrupts
main_loop:
	jmp main_loop

timerOverflowISR:
	; Flip the state of the LED:
	sbi PINC, 0	; Toggle 0 bit

	; Reset the timer
	ldi r16, 1
	out TIFR1, r16	; Reset overflow flag
	; Works even if you don't clear the timer count:
	;ldi r16, 0
	;out TCNT1, r16	; Reset timer count

	reti
