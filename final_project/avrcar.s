;--------------------------------------------------;
; AVRcar					   ;
; Final project for ECE243: Computer Organization. ;
; Luke Volpatti and Yutao Ma			   ;
; April 2018					   ;
;--------------------------------------------------;

.include "../m328Pdef.inc"


jmp reset

;-------------------;
; INTERRUPT VECTORS ;
;-------------------;
; Timer 1 overflow handler
.org 0x001A
jmp timer1_overflow_handler

; ADC handler
.org 0x002A
jmp adc_handler

;--------;
; WIRING ;
;--------;
; PORTC0: Range status LED. This LED will be on if the car is not about to go
;	over the edge.
; PORTC1: Testing LED.
; PORTC2: ADC2. Used for the range sensor.
; PORTB1: Left motor reverse.
; PORTB2: Left motor forward.
; PORTB6: Right motor forward.
; PORTB7: Right motor reverse.


;--------------;
; REGISTER USE ;
;--------------;
; r16-r17: general temporary registers
; r19: ADC flag. Set to 1 once an ADC has completed. When it is 1, reset ADC.
; r20: ADC valid flag. Set to 10 at start of program. Decrement every ADC. 
	; Only take action on ADC reading once this has reached zero. (i.e.
	; throw away 10 first readings)
; r21: Motor reverse flag. ADC ISR sets this to 1 when the motor reverse
	; routine needs to be executed.

;---------------;
; RESET ROUTINE ;
;---------------;
reset:	; Stack initialization
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	; Setting inputs and outputs
	sbi PORTC, 2	; Enable ACD2
	sbi DDRC, 0	; PORTC0 will be range status LED
	sbi DDRC, 1	; PORTC1 is testing LED
	ldi r16, 0b11000110 ; PORTB 1,2 is for left motor. 6,7 for right.
	out DDRB, r16

	; testing
	ldi r16, 0b01000100
	out PORTB, r16
	ldi r20, 10
	ldi r21, 0

	; A status register to see if there's been an interrupt
	ldi r19, 0


;--------------;
; MAIN ROUTINE ;
;--------------;
adc:
	; Making sure ADC can be used
	ldi r16, 0
	sts PRR, r16

	; Configuring ADC
	ldi r16, 0b11001111	; Enable interrupts, prescale 128
	sts ADCSRA, r16
	ldi r16, 0b00100010	; External reference voltage, left adjust, ADC2
	sts ADMUX, r16

	; Resetting r19
	ldi r19, 0

	sei		; Enable global interrupts

loop:
	; Check r19: ADC flag
	cpi r19, 0
	breq loop

	; Check r21: Motor reverse flag
	cpi r21, 0
	breq adc
	call reverse
	ldi r21, 0	; Reset the motor reverse flag
	jmp adc



;-----------------;
; REVERSE ROUTINE ;
;-----------------;
reverse:
; PHASE 1: both motors reverse 1/4s
; PHASE 2: one motor forward other motor backwards 1/4s
; PHASE 3: both motors forward
; Timer 1 is dedicated to the reverse subroutine.
	; Put important registers on the stack so we don't accidentally mess
	; them up.
	;push r19
	;push r20
	;push r21

	; Register r22 will keep track of our state in our mini FSM
	ldi r22, 0
	
timer1_setup:
	ldi r16, 0b00000010	; Set timer prescaler to 8
	sts TCCR1B, r16
	ldi r16, 0b00000001	; Set timer interrupts
	sts TIMSK1, r16
	; Register r23 will keep track of whether a timer interrutp has
	; occured
	ldi r23, 0

reverse_fsm:
	cpi r22, 0
	breq both_motors_reverse_branch
	cpi r22, 1
	breq both_motors_reverse_branch
	cpi r22, 2
	breq one_motor_forward_one_reverse_branch
	cpi r22, 3
	breq both_motors_forward_branch

	;pop r21
	;pop r20
	;pop r19
	
	ret

both_motors_reverse_branch:
	call both_motors_reverse
	inc r22		; Increment r22
	jmp timer1_setup

one_motor_forward_one_reverse_branch:
	call one_motor_forward_one_reverse
	inc r22		; Increment r22
	jmp timer1_setup

both_motors_forward_branch:
	call both_motors_forward
	inc r22		; Increment r22
	jmp timer1_setup

both_motors_reverse:
		ldi r16, 0b10000010
		out PORTB, r16

	loop1:	cpi r23, 0
		breq loop1

		
		ret

one_motor_forward_one_reverse:
		ldi r16, 0b01000010
		out PORTB, r16

	loop2:	cpi r23, 0
		breq loop2

		ret

both_motors_forward:
		ldi r16, 0b01000100
		out PORTB, r16

	loop3: cpi r23, 0
		breq loop3

		ret

;------;
; ISRs ;
;------;
adc_handler:
	; Conversion is complete. Now need to see what the data register holds.
	; Number in the data registers is Vin*1024/Vref. In our case, we want
	; to see if that value ever dips below 200. 
	lds r16, ADCL 	; Lower two bits of reading
	lds r17, ADCH	; Upper eight bits of reading
	lsr r17		; Do a bunch of right shifts
	lsr r17
	lsr r17
	lsr r17
	lsr r17
	lsr r17
	cpi r17, 0b00000001	; Compare r17 to 265
	brlt set_adc_flag  ;Too far; need to execute motor reverse routine

	ldi r16, 1
	out PORTC, r16		; turn on LED
	jmp end_adc_handler

set_adc_flag:
	cpi r20, 0
	breq real
	dec r20
	jmp end_adc_handler

real:
	ldi r16, 0		; turn off LED
	out PORTC, r16

	; TESTING
	;ldi r16, 0b10000010
	;out PORTB, r16
	ldi r21, 1

	jmp end_adc_handler

end_adc_handler:
	ldi r19, 1
	reti


timer1_overflow_handler:
	ldi r23, 1
	ldi r16, 1
	out TIFR1, r16
	reti
