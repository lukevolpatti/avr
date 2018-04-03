.include "../m328Pdef.inc"

jmp reset

; This is where to go when the external interrupt INT0 occurs
.org 0x0002
jmp externalISR


reset:	; Stack initialization:
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	; Setting inputs and outputs
	sbi DDRC, 0	; Set PORTC0 to output
	
	; Setting external interrupt setting
	ldi r16, 0b00000010	; The falling edge of INT0 sets interrupt
	sts EICRA, r16		; External Interrupt Control Register A
	
	; Enabling external interrupts:
	ldi r16, 0b00000001 ; only enable interrupt from INT0
	out EIMSK, r16

	; Globally enabling interrupts:
	sei

; Main loop, in which we do nothing but wait for interrupts
main_loop:
	jmp main_loop

externalISR:
	; Flip the state of the LED:
	;ldi r16, 1
	;out PINC, r16
	sbi PINC, 0	; Toggle 0 bit

	; Reset the flag
	ldi r16, 1
	out EIFR, r16	; Reset flag

	reti
