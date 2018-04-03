.include "../m328Pdef.inc"

jmp reset

; External Interrupt 0 (INT0) handler
; Used for response from sonar
.org 0x0002
jmp externalISR

; Timer overflow handler
.org 0x0020
jmp timerOverflowISR

;---------------;
; RESET ROUTINE ;
;---------------;
reset:	; Stack initialization
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	; Setting inputs and outputs
	sbi DDRC, 0	; Set PORTC0 to output
	;sbi DDRD, 0	; Set PORTD0 to output. This is for sonar trigger.
			; Set PORTD1 to input. This is for sonar echo.
			; CHECK THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	ldi r16, 1
	out DDRD, r16

	; Setting timer
	ldi r16, 0b00000011	; Set timer prescaler to /64
	out TCCR0B, r16		; Timer control register

	; Setting external interrupts
	ldi r16, 0b00000010	; Falling edge of INT0 sets interrupt
	sts EICRA, r16		; External interrupt control register

	; NEED TO SET TIMER, EI, AND GLOBAL INTERRUPTS!


;--------------;
; MAIN ROUTINE ;
;--------------;
main_loop:
	cli	; Disable interrupts for now
	ldi r19, 0	; r19 will keep track of whether we've had
			; and interrupt

	; Step 1: set sonar trigger
	rcall trigger

	; Step 2: set up interrupts while we're waiting for the echo
	; signal to go high.
	rcall waitForEcho

	; Step 3: do nothing while we wait
do_nothing:
	cpi r19, 0
	breq do_nothing
	ldi r19, 0
	jmp main_loop

;-------------;
; SUBROUTINES ;
;-------------;
trigger:
	; Setting the trigger
	ldi r16, 1	; Sending a 1 to the sonar
	out PORTD, r16	; Via the trigger output
	
	; Counting down
	; We need to set the trigger high for 10 microseconds.
	; Onboard clock is at ~1MHz, so can have a variable initialized
	; to 5 and decrement it in a loop. There are two instruction in
	; the loop, so each iteration of the loop will take 2 microseconds.
	ldi r16, 10	; Setting initial value of 5
count:	dec r16		; Decrement counting variable
	brne count	; Loop if we're not at 0.
	
	; We've broken out of the counter at this point. Can set
	; the trigger back to 0.
	ldi r16, 0
	out PORTD, r16
	ret


waitForEcho:
	; Setup
	ldi r16, 1	; We will use r16 to turn on both the timer's and
			; INT0's interrupt enables once echo comes high

pollForEchoHigh:
	in r17, PORTD		; Get PORTB
	andi r17, 0b00000100	; Check if bit 2 is high. This bit
				; corresponds to the echo
	breq pollForEchoHigh	; Echo is low. Loop.

	; We made it! Echo is high, the action starts now!
	; Set timer count to appropriate value
	ldi r17, 240		; Overflow occurs at 255.
	out TCNT0, r17

	; Enable timer, global, and INT0 interrupts
	sts TIMSK0, r16
	out EIMSK, r16
	sei


;------;
; ISRs ;
;------;
timerOverflowISR:
	; Timer won!
	; Object is too far away. Set LED to low.
	ldi r16, 0
	out PINC, r16

	; Reset the timer
	ldi r16, 1
	out TIFR0, r16	; Reset overflow flag

	; Reset external ISR in case
	out EIFR, r16	; Reset flag

	; Signal that we've had an interrupt
	ldi r19, 1

	reti

externalISR:
	; Sonar won!
	; Object is close enough. Set LED to high.
	ldi r16, 1
	out PINC, r16

	; Reset the timer
	out TIFR0, r16

	; Reset external ISR
	out EIFR, r16

	; Signal that we've had an interrupt
	ldi r19, 1

	reti
