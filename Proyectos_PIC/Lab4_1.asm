 
;Exercise 4.1. Write a program that digitizes the analogue signal connected to channel AN1 and displays 
;its value on 10 LEDs, with the 2 most significant bits of the resulting value connected to pins PORTC[1:0] 
;and the 8 least significant bits connected to PORTB. The sampling frequency of the analogue signal is 
;800 Hz, i. e., A/D conversion must be performed at 800 Hz. 
;The AD converter must be configured with reference voltages VREF+ = VDD and VREF- = VSS. 
;The AD conversion clock must be the fastest that guarantees to meet the time conversion requirements. 
;Use Timer0 and its interrupt to generate the timing corresponding to the sampling frequency of 800 Hz. 
;Use the A/D interrupt in order to know when the conversion is complete and the result can be read. 
;In order to generate an analog signal, use the potentiometer in the PICSchool board as indicated in the 
;figure. 













	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF


org 0
goto inicio
org 4
goto ISR
org 5

inicio:

	BSF 	STATUS,RP0
	CLRF	TRISB
	CLRF	TRISC	
	MOVLW	B'11111111'
	MOVWF	TRISA	
	BSF		ADCON1,ADFM
	BCF		ADCON1,PCFG3
	BCF		ADCON1,PCFG2
	BCF		ADCON1,PCFG1
	BCF		ADCON1,PCFG0
	BCF 	STATUS,RP0
	BSF		ADCON0,CHS0
	BSF		ADCON0,ADCS0
	
	BSF		ADCON0,ADON ;ACTIVO EL CONVERSOR	
	
	;ACTIVO EL TMR0
	
	BSF		STATUS,RP0
	BCF		OPTION_REG,T0CS
	BCF		OPTION_REG,PSA		; TIENES QUE ASIGNARLE EL PRESCALER A L TIMER0
	BCF		OPTION_REG,PS0 ;OBLIGATORIO TOCAR TANTO EL PS2,PS1,PS0 NO SUPONGAS NADA
	BSF		OPTION_REG,PS1
	BCF		OPTION_REG,PS2
	BSF		PIE1,ADIE
	BCF		STATUS,RP0
	BSF		INTCON,GIE
	BSF 	INTCON,T0IE
	BSF		INTCON,PEIE
	movlw 	.105
	movwf	TMR0



main
	goto main



ISR:
	

	BTFSC	INTCON,T0IE
		GOTO	ISR_TMR0
		GOTO	ISR_AD


ISR_TMR0:  ;SI SALTO AQUÍ. LA PRIMERA VEZ DEBO SALTAR AQUÍ, Y LUEGO PONER EN MARCHA EL CONVERSOR, LUEGO CUANDO SALTE LA INTERRUPCION DEL AD ES PORQUE SE HA HECHO YA LA CONVERSION 
			;Y DEBO COGER LA INFORMACION QUE ESTARÍA EN DIGITAL
	
	BCF INTCON, T0IE
	MOVLW .105
	MOVWF	TMR0
	BSF	ADCON0,GO ; PONGO EN MARCHA LA CONVERSION
	RETFIE
	

ISR_AD:
	

	MOVF 	ADRESH,0
	MOVWF	PORTC
	BSF		STATUS,RP0
	MOVF	ADRESL,0
	BCF		STATUS,RP0
	MOVWF	PORTB
refie
	
	

end