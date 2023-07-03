;*******************************************
;Lab 5, Section 2
;Name: Steven Miller
;Class #: 11318
;PI Name: Anthony Stross
;Description: transmits character over serial usb line
;*******************************************

;***************INCLUDES*************************************
.include "ATxmega128a1udef.inc"
;***************END OF INCLUDES******************************

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
	loop:
		ldi r16,'U'
		rcall OUT_CHAR
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
	;set port d pin 3 as output
	ldi r16, 0b00001000
	sts PORTD_OUTSET,r16
	sts PORTD_DIRSET, r16
	;enable transmitter
	ldi r16, 0b00001000
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
	pop r16
ret
;****************************************************
; Name: OUT_CHAR
; Purpose:TRANSMIT CHARACTER OUT OF PORT D TO USB
; Input(s): N/A
; Output: USARTD0_DATA
;****************************************************
OUT_CHAR:
	push r17
	;check if transmitter busy
	transmitter_busy:
	lds r17, USARTD0_STATUS
	sbrs r17, USART_DREIF_bp
	rjmp transmitter_busy
	;ldi r17, 0b0
	;load character into transmitter data register
	sts USARTD0_DATA, r16
	pop r17
ret
