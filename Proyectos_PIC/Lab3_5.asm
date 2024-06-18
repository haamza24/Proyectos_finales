

;Exercise 3.5. Write a program that increments the value of PORTC when a button connected to pin RB4 is pressed2, 
;decrements the value of PORTC when a button connected to RB5 is pressed and resets the value of PORTC when a 
;button connected to RB6 is released. PORTC must be cleared at initialization


	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF


exPortb equ 0x20  ; ponerle una directiva a la posicion de memoria 21
resXor	equ	0x21

org 0
goto inicio
org 4
goto ISR
org 5

inicio:
	
	BSF STATUS,RP0
	CLRF	TRISC
	BSF 	TRISB,RB4
	BSF		TRISB,RB5
	BSF		TRISB,RB6
;	CLRF 	TRISB
	
	
	BCF 	STATUS,RP0
	BSF		INTCON,GIE
	BSF 	INTCON,RBIE
;	CLRF	PORTB
;	CLRF	PORTC
	MOVF 	PORTB,0
	MOVWF	exPortb
	

main
	goto main

	

ISR:
	MOVF	PORTB,0   ; super IMPORTANTe leer el PORTB antes que vaciarlo
	BCF 	INTCON,RBIF
	XORWF	exPortb,0
	MOVWF	resXor
	MOVF 	PORTB,0 	 ;guardo el valor de PORTB DE NUEVO 
	MOVWF	exPortb		 ; idem

	btfsc 		resXor,4
		goto 	interrupcion_4
		goto 	ver_interrupcion_5_6

ver_interrupcion_5_6:
	BTFSC 		resXor,5
		goto	interrupcion_5
		goto	ver_interrupcion_6

ver_interrupcion_6:
	BTFSC		resXor,6
		goto	interrupcion_6
		retfie

interrupcion_4:  ;debo ver si ha ocurrido un pressed 1->0
		btfsc	PORTB,4 ;si es 0 es porque ha ocurrido un press
			retfie	
			goto incrementar
		
incrementar:	
		INCF PORTC,1
		retfie

interrupcion_5:	;debo verificar si ha ocurrido un pressed 1->0
		btfsc	PORTB,5
			retfie
			goto decrementar
decrementar:
		decfsz PORTC,1
		retfie

interrupcion_6: ;debo verifica si ha ocuurido un released 0->1
		btfsc 	PORTC,6
			retfie
			goto limpiar
	
limpiar:
		clrf PORTC
		retfie


end