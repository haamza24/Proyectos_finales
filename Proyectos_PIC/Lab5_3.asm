
;Exercise 5.3. Modify exercise 5.3 in such a way that the microcontroller waits for a 4-data reception 
;and then returns to the PC either “ACTIVADO”, when the received data are “s1on”; “PAUSADO”, when 
;the received data are “s1pa”; “OFF” when the received data are “s1of”; a data packet consisting of the  
;ASCII  characters  “ERR1”  and  the  4-data  packet  received  when  receiving  any  other  4-data  packet 
;starting with “s1”; or a data packet consisting of the ASCII characters “ERR2” and the 4-data packet 
;received when the 4-data received packet do not start with “s1”.  





	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	NUM_DATOS_TX  EQU 0X20
	PUNTERO_TX 	EQU 0X21
	DATO1		EQU 0X22
	DATO2		EQU 0X23
	DATO3		EQU	0X24
	DATO4 		EQU 0X25
	PUNTERO_RX	EQU 0X26
	NUM_DATOS_RX EQU 0X27




org 0
goto inicio
org 4
goto ISR
org 5

inicio:
	BSF STATUS,RP0
	BSF TRISC,RC7
	BCF	TRISC,RC6
	;TXSTA
	BCF TXSTA,TX9
	BSF	TXSTA,TXEN
	BCF	TXSTA,SYNC
	BSF	TXSTA,BRGH
	MOVLW	.12
	MOVWF	SPBRG

	;RCSTA
	BCF		STATUS,RP0
	BSF 	RCSTA,SPEN
	BCF		RCSTA,RX9
	BSF		RCSTA,CREN

	BSF 	STATUS,RP0
	BSF 	INTCON,GIE
	BSF	 	INTCON,PEIE
	BSF		PIE1,RCIE
	BCF 	STATUS,RP0
	MOVLW	.4
	MOVWF 	NUM_DATOS_RX
	MOVLW 	0X22
	MOVWF	PUNTERO_RX

main
		goto main





ISR:

		BTFSC		PIR1,RCIF
			goto 	recepcion
			goto	transmision


recepcion:

		MOVF	PUNTERO_RX,0
		MOVWF	FSR
		MOVF 	RCREG,0
		MOVWF	INDF
		DECFSZ	NUM_DATOS_RX,1
			goto seguir_recibiendo
			goto fin_recepcion
		
	
	seguir_recibiendo:
		incf PUNTERO_RX,1
		retfie


fin_recepcion:
		;PREPARO PARA LA SIGUIENTE RECEPCION
	MOVLW	.4
	MOVWF 	NUM_DATOS_RX
	MOVLW 	0X22
	MOVWF	PUNTERO_RX

	;CHEKEO QUE HE RECIBIDO



		movlw	's'
		subwf	DATO1,0
		BTFSC	STATUS,Z
			GOTO	CHECK_1
			GOTO 	ENVIAR_ERROR2

CHECK_1:
		MOVLW		 '1'
		subwf		DATO2,0
		BTFSC		STATUS,Z
			GOTO	CHECK_O				;S1
			GOTO	 ENVIAR_ERROR2			;S-


CHECK_O:
		MOVLW	'o'
		subwf	DATO3,0
		BTFSC	STATUS,Z
			GOTO	CHECK_N			;s1o
			GOTO 	CHECK_P				;S1-	

CHECK_P:

	MOVLW 'p'
	subwf	DATO3,0
	BTFSC	STATUS,Z
		GOTO	CHECK_a			;s1p
		GOTO	ENVIAR_ERROR1	;s1-


CHECK_a:
		MOVLW	'a'
		subwf	DATO4,0
		btfsc	STATUS,Z
			GOTO	ENVIAR_PAUSADO		;s1pa
			GOTO	ENVIAR_ERROR1				;s1p-





CHECK_N:


		MOVLW	'n'
		subwf	DATO4,0
		BTFSC	STATUS,Z
			GOTO	ENVIAR_ACTIVADO		;s1on
			GOTO 	CHECK_f			;S1o-	

CHECK_f:

	MOVLW	'f'
		subwf	DATO4,0
		BTFSC	STATUS,Z
			GOTO	ENVIAR_OFF		;s1of
			GOTO 	ENVIAR_ERROR1			;s1o-	




ENVIAR_ACTIVADO:

movlw 'A'
movwf 0x40

movlw 'C'
movwf 0x41

movlw 'T'
movwf 0x42

movlw 'I'
movwf 0x43

movlw 'V'
movwf 0x44

movlw 'A'
movwf 0x45

movlw 'D'
movwf 0x46

movlw 'O'
movwf 0x47

MOVLW 	.8
MOVWF 	NUM_DATOS_TX


MOVLW 0X40
MOVWF	PUNTERO_TX 

CALL ACTIVA_TXIE
retfie




ENVIAR_ERROR1:

movlw 'E'
movwf 0x40

movlw 'R'
movwf 0x41

movlw 'R'
movwf 0x42

movlw 'O'
movwf 0x43

movlw 'R'
movwf 0x44

movlw '1'
movwf 0x45



MOVLW 	.6
MOVWF 	NUM_DATOS_TX


MOVLW 0X40
MOVWF	PUNTERO_TX 

CALL ACTIVA_TXIE
retfie






ENVIAR_ERROR2:

movlw 'E'
movwf 0x40

movlw 'R'
movwf 0x41

movlw 'R'
movwf 0x42

movlw 'O'
movwf 0x43

movlw 'R'
movwf 0x44

movlw '2'
movwf 0x45



MOVLW 	.6
MOVWF 	NUM_DATOS_TX


MOVLW 0X40
MOVWF	PUNTERO_TX 

CALL ACTIVA_TXIE
retfie

	


ENVIAR_OFF:
MOVLW 'O'
MOVWF 0X40
MOVLW 'F'
MOVWF 0X41
MOVLW 'F'
MOVWF 0X42

MOVLW .3
MOVWF NUM_DATOS_TX

MOVLW	0X40
MOVWF	PUNTERO_TX
CALL ACTIVA_TXIE

RETFIE



ENVIAR_PAUSADO:
MOVLW 'P'
MOVWF 0X40
MOVLW 'A'
MOVWF 0X41
MOVLW 'U'
MOVWF 0X42
MOVLW 'S'
MOVWF 0X43
MOVLW 'A'
MOVWF 0X44
MOVLW 'D'
MOVWF 0X45
MOVLW 'O'
MOVWF 0X46


MOVLW .7
MOVWF NUM_DATOS_TX

MOVLW	0X40
MOVWF	PUNTERO_TX
CALL	 ACTIVA_TXIE
RETFIE


ACTIVA_TXIE:
	BSF	STATUS,RP0
	BSF	PIE1,TXIE
	BCF	STATUS,RP0
return





transmision:

		movf 	PUNTERO_TX,0
		movwf	FSR
		movf	INDF,0
		movwf 	TXREG
		
bf			DECFSZ	NUM_DATOS_TX,1
			goto seguir_enviando
			goto fin_envio



seguir_enviando:
	incf PUNTERO_TX,1
	retfie


fin_envio:
;DESACTIVO EL ENVIO
BSF STATUS,RP0
BCF	PIE1,TXIE
BCF STATUS,RP0
RETFIE

	
	




	retfie


end




