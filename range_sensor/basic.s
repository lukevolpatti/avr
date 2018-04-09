.include "../m328Pdef.inc"

jmp reset

; ADC handler interrupt vector
.org 0x002A
jmp adc_handler

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
	sbi DDRC, 0	; PORTC0 will be LED
	sbi DDRC, 1	; PORTC1 is testing LED

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
	ldi r16, 0b00100010	; External reference voltage,
				; left adjust, ADC2
	sts ADMUX, r16

	; Resetting r19
	ldi r19, 0

	sei		; Enable global interrupts

loop:
	; See if r19 has been set yet (i.e. interrupt has occured)
	cpi r19, 0
	breq loop
	jmp adc


;-----;
; ISR ;
;-----;
adc_handler:
	; Conversion is complete. Now need to see what the data register hold.
	; Number in the data registers is Vin*1024/Vref. In our case, we want
	; to see if that value ever dips below 200. 
	lds r16, ADCL 	; Lower two bits of reading
	lds r17, ADCH	; Upper eight bits of reading
	lsr r17
	lsr r17
	lsr r17
	lsr r17
	lsr r17
	lsr r17
	cpi r17, 0b00000001	; Compare r17 to 265
	brlt led_off		; Too far; turn led off

	ldi r16, 1
	out PORTC, r16		; turn on LED
	jmp end_adc_handler

led_off:
	ldi r16, 0		; turn off LED
	out PORTC, r16
	jmp end_adc_handler

end_adc_handler:
	ldi r19, 1
	reti
