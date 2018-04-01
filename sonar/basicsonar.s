.include "../m328Pdef.inc"
.def temp = r20

;-------;
; SETUP ;
;-------;
.org 0000	; Can start at end because we don't need interrupts

; Setting inputs and outputs:
sbi DDRC, 0	; set PORTC0 to output. This will be for the LED.
sbi DDRB, 0	; set PORTB0 to output. This will be for the sonar trigger
		; Also set PORTB1 to input. This will be for the sonar echo.

; Setting timer
ldi temp, 0b00000101	; set timer prescaler to 1024
out TCCR0B, temp	; TCCR0B is the control register for timer 0

; Stack pointer initialization
LDI    R16,  low(RAMEND)  ; Load the lower 8 bits of the final address in RAM
OUT    SPL,  R16		  ; Store the lower 8 bits of the final adress in RAM
						  ; in the low register of the stack pointer
LDI    R16,  high(RAMEND) ; Load the upper 8 bits of the final address in RAM
OUT    SPH,  R16		  ; Store the upper 8 bits of the final address in RAM
						  ; in the high register o fthe stack pointer

;--------------;
; MAIN ROUTINE ;
;--------------;
main_loop:
	; STEP 1: send out sound wave
	rcall pulse

	; STEP 2: calculate time to receive response
	rcall response_time

	; STEP 3: toggle LED if necessary

	; SETP 4: repeat
	rjmp main_loop


;---------------;
; LOOP ROUTINES ;
;---------------;
pulse:	ldi temp, 0b00000001	; Send a 1 to the sonar
	out portb, temp
	ldi temp, 5		; count to 12 microseconds
count:	dec temp		; decrement our counter
	brne count		; loop if counter is not zero
	
	; if we get here, we've broken out of the counter
	ldi temp, 0		; set the sonar back to zero
	out portb, temp
	ret

response_time:

waitforecho:
	; Keep looping until the sonar responds
	in temp, portc
	andi temp, 0b00000010
	cpi temp, 0
	breq waitforecho


	ldi temp, 0	; clear the timer
	out TCNT0, temp	; TCNT0 is timer 0's counter value reg


	

wait:	in temp, TIFR0  	; TIFR0 is timer 0 interrupt flag reg
	andi temp, 0b00000010	; check if timer is done
	cpi temp, 0
	brne LEDoff		; turn the LED off

	in r17, TCNT0		; get timer count
	in r18, PORTB		; get port b's status
	andi r18, 0b00000010	; check if r18 is 0
	cpi r18, 0
	brne wait		; loop if no response yet
	;lsr r17
	cpi r17, 1
	brge LEDoff

LEDon:	ldi temp, 1	; write 1 to led
	out portc, temp
	ldi temp, 0b00000010
	out TIFR0, temp
	ret

LEDoff:
	ldi temp, 0
	out portc, temp
	ldi temp, 0b00000010
	out TIFR0, temp
	ret
