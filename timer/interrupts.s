.include "../m328Pdef.inc"

jmp reset

; This is where to go when the timer overflow interrupts
.org 0x0020
jmp timerOverflowISR


reset:	; Stack initialization:
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	; Setting inputs and outputs
	sbi DDRC, 0	; Set PORTC0 to output
	
	; Setting timer
	ldi r16, 0b00000101	; Set timer prescaler to 1024
	out TCCR0B, r16
	
	; Enabling timer's interrupts:
	ldi r16, 0b00000001
	sts TIMSK0, r16

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
	out TIFR0, r16	; Reset overflow flag
	ldi r16, 0
	out TCNT0, r16	; Reset timer count

	reti
