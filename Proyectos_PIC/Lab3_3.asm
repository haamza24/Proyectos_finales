
;Exercise 3.3. Write a program using the Timer 0 module and its interrupt on overflow that increases the value of 
;variable CICLO_1_8ms every 1,8 ms. CICLO_1_8ms must be cleared during initialization.



	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF


ciclo_1_80 equ 0x21  ; ponerle una directiva a la posicion de memoria 21

org 0
goto inicio
org 4
goto ISR
org 5

inicio:
	

	BSF 	STATUS,RP0
	BCF 	OPTION_REG,T0CS
	BCF		OPTION_REG,PSA
	BCF		OPTION_REG,PS2
	BSF		OPTION_REG,PS1
	BCF		OPTION_REG,PS0
	BCF		STATUS,RP0
	BSF 	INTCON,GIE
	BSF		INTCON,T0IE
	MOVLW	.31
	MOVWF 	TMR0
	CLRF 	ciclo_1_80
	
	main	
		goto main
	
	
	ISR:
	
	BCF INTCON,T0IF
	INCF ciclo_1_80,1
	MOVLW .31
	MOVWF	TMR0
	RETFIE
	END	

	
