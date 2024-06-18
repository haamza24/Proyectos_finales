

;Exercise 3.2.  Write  a  program  using  the  Timer  0  module  and  its  interrupt  on  overflow  to  increase  variable 
;CICLO_120us every 120 µs. CICLO_120us must be cleared during initialization.



	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF


  ; ponerle una directiva a la posicion de memoria 21

org 0
goto inicio
org 4
goto ISR
org 5

inicio:
ciclo_120 equ 0x21
	BSF		INTCON,GIE
	BSF 	INTCON,T0IE
	BSF 	STATUS,RP0
	BCF 	OPTION_REG,T0CS
	BSF 	OPTION_REG,PSA
	BCF		STATUS,RP0
	CLRF	ciclo_120
	CLRF 	TMR0
	MOVLW 	.136
	MOVWF	TMR0
	

	MAIN	
		
		GOTO MAIN
	

ISR:
	
	BCF INTCON,T0IF
	INCF ciclo_120
	MOVLW .136
	MOVWF TMR0
	RETFIE
	END
