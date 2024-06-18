
;Exercise 5.2. Modify exercise 5.2 in such a way that the microcontroller waits for a 4-data reception 
;and then returns to the PC either �ACTIVADO�, when the received data are �s1on�; �PAUSADO�, when 
;the received data are �s1pa�; �OFF� when the received data are �s1of�; �ERR1� when receiving any 
;other 4-data packet starting with �s1�; or �ERR2� when the 4-data received packet do not start with :
;�s1�.  



	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	DATOS_TX  EQU 0X20
	PUNTERO_TX EQU 0X21
	DATO1		EQU 0X22



org 0
goto inicio
org 4
goto ISR
org 5

inicio:

BSF STATUS,RP0
BSF	TRISC,RC7
BSF TRISC,RC6
;TXSTA

BCF TXSTA,TX9
BCF	TXSTA,SYNC
BSF	TXSTA,BRGH
BSF TXSTA,TXEN
MOVLW	.12
MOVWF	SPBRG

;RCSTA
BSF	PIE1,RCIE
BCF STATUS,RP0
BSF RCSTA,SPEN
BCF	RCSTA,RX9
BSF RCSTA,CREN
BSF INTCON,GIE

BSF INTCON,PEIE
BCF STATUS,RP0

main 
goto main

ISR:

	BTFSC PIR1,RCIF
	GOTO RECEPCION
	GOTO TRANSMISION
	

RECEPCION:
	MOVF RCREG,0
	MOVWF	DATO1
	MOVLW 'A'
	SUBWF DATO1,0
	BTFSC	 STATUS,Z
	GOTO ENVIAR_ACTIVADO
	GOTO VERIFICAR_P_O

VERIFICAR_P_O:

MOVLW 'P'
SUBWF DATO1,0
BTFSC STATUS,Z
GOTO ENVIAR_PAUSADO
GOTO VERIFICAR_O

VERIFICAR_O:
MOVLW 'O'
SUBWF DATO1,0
BTFSC STATUS,Z
GOTO ENVIAR_OFF
GOTO ENVIAR_NADA

ENVIAR_ACTIVADO:
MOVLW 'A'
MOVWF 0X40
MOVLW 'C'
MOVWF 0X41
MOVLW 'T'
MOVWF 0X42
MOVLW 'I'
MOVWF 0X43
MOVLW 'V'
MOVWF 0X44
MOVLW 'A'
MOVWF 0X45
MOVLW 'D'
MOVWF 0X46
MOVLW 'O'
MOVWF 0X47

MOVLW .8
MOVWF DATOS_TX

MOVLW	0X40
MOVWF	PUNTERO_TX
CALL ACTIVA_TXIE
RETFIE

ENVIAR_NADA:

RETFIE


ENVIAR_OFF:
MOVLW 'O'
MOVWF 0X40
MOVLW 'F'
MOVWF 0X41
MOVLW 'F'
MOVWF 0X42

MOVLW .3
MOVWF DATOS_TX

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
MOVWF DATOS_TX

MOVLW	0X40
MOVWF	PUNTERO_TX
CALL ACTIVA_TXIE
RETFIE





ACTIVA_TXIE:
BSF STATUS,RP0
BSF PIE1,TXIE
BCF STATUS,RP0
RETURN


TRANSMISION:

MOVF PUNTERO_TX,0
MOVWF FSR
MOVF INDF,0
MOVWF TXREG

DECFSZ DATOS_TX
GOTO	SEGUIR_TX
GOTO	FIN_TX


SEGUIR_TX:
INCF PUNTERO_TX,1
RETFIE

FIN_TX:
BSF STATUS,RP0
BCF	PIE1,TXIE
BCF STATUS,RP0
RETFIE

END



	
