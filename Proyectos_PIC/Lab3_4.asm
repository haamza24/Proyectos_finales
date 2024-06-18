
;Exercise 3.4. Write a program using  the Timer 0 module and its interrupt on overflow  that counts minutes and 
;seconds,  using  the  MINUTOS  and  SEGUNDOS  variables,  respectively.  Both  variables  must  be  cleared  during 
;initialization. When the values of MINUTOS and SEGUNDOS are 59, their next values should be 0.

	LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

segundos  EQU 0X20
minutos	  EQU 0X21
contador_segundos EQU 0X22
contador_minutos EQU 0X23


org 0
goto inicio
org 4
goto ISR
org 5



inicio:

BSF STATUS,RP0
BCF	OPTION_REG,T0CS
BCF	OPTION_REG,PSA
BSF	OPTION_REG,PS2
BSF	OPTION_REG,PS1
BSF	OPTION_REG,PS0
BSF	INTCON,GIE
BSF	INTCON,T0IE
BCF STATUS,RP0
MOVLW .61
MOVWF	TMR0
CLRF	segundos
clrf	minutos
MOVLW .60
MOVWF contador_minutos
MOVLW	.20
MOVWF	contador_segundos



main 	
		goto main



ISR:
		BTFSC	INTCON,T0IF
				GOTO INT_TMR0
				GOTO INT_OTRA_INTR





INT_TMR0:	BCF 	INTCON,T0IF
			DECFSZ	contador_segundos,1
					goto seguir_gastando
					goto incrementar_segundos
							


seguir_gastando:

		MOVLW .61
		MOVWF TMR0
		RETFIE

incrementar_segundos:
			incf segundos,1
			decfsz	 contador_minutos,1
						goto	seguir_gastando_segundos
						goto	incrementar_minutos


seguir_gastando_segundos:
		MOVLW .61
		MOVWF TMR0
		MOVLW	.20
		MOVWF	contador_segundos
		RETFIE
			
				
incrementar_minutos:
		incf minutos,1
		MOVLW	.20
		MOVWF	contador_segundos
		MOVLW .61
		MOVWF TMR0	
MOVLW .60
MOVWF contador_minutos
retfie
		
		

INT_OTRA_INTR:		

		RETFIE



end