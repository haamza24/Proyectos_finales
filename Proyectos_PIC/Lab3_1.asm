
;Exercise 3.1. Write a program that increments the value of PORTC when a push button connected to pin RB0 is 
;released1  PORTC must be cleared during initialization. 

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
	BSF	 	TRISB,RB0
	CLRF	TRISC
	BSF 	OPTION_REG,INTEDG
	BCF 	STATUS,RP0
	BSF		INTCON,GIE
	BSF		INTCON,INTE
	CLRF 	PORTC
	

main 
goto main

ISR:
	BCF 	INTCON,INTF
	IINCF	PORTC,1
	retfie

	End





