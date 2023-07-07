;*******************************************
;Lab 5, Section 7
;Name: Steven Miller
;Class #: 11318
;PI Name: Anthony Stross
;Description: recieves serial data from computer using interrupts
;*******************************************
;*********************************EQUATES********************************
.equ bsel = 47
.equ bscale = -6
;*******************************END OF EQUATES*******************************

;*********************************DEFS********************************
;*******************************END OF DEFS*******************************

;***********PROGRAM MEMORY CONFIGURATION*************************
;***********END OF PROGRAM MEMORY CONFIGURATION***************

;***********DATA MEMORY CONFIGURATION*************************

;***********END OF DATA MEMORY CONFIGURATION***************

;***********MAIN PROGRAM*******************************
.CSEG
.org USARTD0_RXC_vect
	rjmp in_char
.org 0x0000
	rjmp main
.org 0x0200
	
main:
	;initialize stack
	ldi r16, low(0x3fff)
	out CPU_SPL, r16
	ldi r16, high(0x3fff)
	out CPU_SPH, r16
	rcall USART_INIT
	;initialize blue led
	ldi r16, 0b01000000
	sts PORTD_DIRSET,r16
	ldi r16, 0b10111111
	sts PORTD_OUT,r16
	ldi r16, 0b01000000
	loop:
		sts PORTD_OUTTGL,r16
	rjmp loop
end:
rjmp end

;****************************************************
; Name: USART_INIT
; Purpose: INITIALIZE USART MODULE ON PORT D
; Input(s): N/A
; Output: N/A
;****************************************************
USART_INIT:
	push r16
	;set port d pin 2 as input and port d pin 3 as output
	ldi r16, 0b00000100
	sts PORTD_OUTCLR,r16
	sts PORTD_DIRCLR, r16
	ldi r16, 0b00001000
	sts PORTD_OUTSET,r16
	sts PORTD_DIRSET, r16
	;enable transmitter and reciever
	ldi r16, 0b00011000
	sts USARTD0_CTRLB, r16
	;set transmission to asynchronous and parity to odd 
	;and set number of stop bits to 1 and set character size to 8 bits
	ldi r16,(USART_PMODE_ODD_gc|USART_CMODE_ASYNCHRONOUS_gc|USART_CHSIZE_8BIT_gc)
	sts USARTD0_CTRLC, r16
	;set baud rate to 72000 bps
	;bsel = 47
	;bscale = -6
	ldi r16, low(bsel)
	sts USARTD0_BAUDCTRLA, r16
	ldi r16, ((bscale<<4) | (high(bsel))) ;1010 = -6
	sts USARTD0_BAUDCTRLB, r16
	;set interrupt level to medium
	ldi r16, 0b00100000
	sts USARTD0_CTRLA, r16
	;enable global interrupts
	ldi r16, 0b00000010
	sts pmic_ctrl, r16
	sei
	pop r16
ret
;****************************************************
; Name: IN_CHAR
; Purpose: reciever ISR
; Input(s):USARTD0_DATA
; Output:N/A
;****************************************************
IN_CHAR:
	push r17
	push r16
	lds r16, CPU_SREG
	push r16
	;load character from reciever data register
	lds r18, USARTD0_DATA
	;check if transmitter busy
	transmitter_busy:
	lds r17, USARTD0_STATUS
	sbrs r17, USART_DREIF_bp
	rjmp transmitter_busy
	;load character into transmitter data register
	sts USARTD0_DATA, r18
	pop r16
	sts CPU_SREG, r16
	pop r16
	pop r17
reti


