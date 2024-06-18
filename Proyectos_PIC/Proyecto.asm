LIST P= 16F876A
	include "p16f876a.inc"
__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	exPortb  				EQU 0X20
	resXor 					EQU 0X21
	segundos				EQU 0X22
	estados					EQU 0X23
	contador_segundos		EQU	0X24
	umbral0					EQU 0X25
	umbral1					EQU 0X26
	umbral3 				EQU 0X27
	canal0					EQU 0X28
	canal1					EQU	0X29
	canal3					EQU	0X2A
	numero_de_segundos 		EQU 0X2B
	carga_segundos 			EQU 0X2C

	long_transmision		EQU	0X2D
	long_recepcion			EQU	0X2E
	puntero_transmision		EQU 0X2F
	puntero_recepcion		EQU 0X30
	CONT2					EQU 0X3A
	CONT1					EQU 0X3B
	DATO1					EQU	0X31
	DATO2					EQU	0X32
	DATO3					EQU 0X33
	DATO4					EQU 0X34
	DATO5					EQU	0X35
	



org 0
goto inicio
org 4
goto ISR
org 5

inicio:
clrf DATO1
clrf DATO2
clrf DATO3
clrf DATO4
clrf DATO5
clrf long_transmision
clrf long_recepcion	
clrf puntero_transmision
clrf puntero_recepcion
clrf estados
CLRF segundos
CLRF numero_de_segundos
BSF STATUS,RP0
BSF TRISA,0
BSF	TRISA,1
BSF TRISA,3
BCF TRISB,1
BCF	TRISB,2
BCF	TRISB,3
BSF	TRISB,7
BSF	TRISB,6
BSF	TRISB,5
BSF	TRISB,4
CLRF TRISC
BSF	TRISC,7
BCF	OPTION_REG,T0CS 
BCF	OPTION_REG,PSA
BSF	OPTION_REG,PS2
BSF	OPTION_REG,PS1
BSF	OPTION_REG,PS0
BSF	PIE1,ADIE
BSF	PIE1,RCIE
BSF	INTCON,PEIE
BSF	INTCON,T0IE
BSF	INTCON,INTE
BSF	INTCON,RBIE
BSF INTCON,GIE
BCF STATUS,RP0
BSF	ADCON0,ADCS1
BCF	ADCON0,ADCS0
BSF	ADCON0,ADON
BCF	ADCON0,ADFM
BSF STATUS,RP0
BCF	ADCON1,PCFG3
BCF	ADCON1,PCFG2
BCF	ADCON1,PCFG1
BCF	ADCON1,PCFG0

;USART;	
BCF	TXSTA,TX9
BSF	TXSTA,TXEN
BCF	TXSTA,SYNC
BSF	TXSTA,BRGH
MOVLW	.25
MOVWF	SPBRG

BCF	STATUS,RP0
BSF	RCSTA,SPEN
BCF	RCSTA,RX9
BSF	RCSTA,CREN

MOVLW	.5
MOVWF	long_recepcion

MOVLW	0X31
MOVWF	puntero_recepcion


MOVLW .61
MOVWF TMR0
MOVF PORTB,0
MOVWF	exPortb
BSF	estados,0 ;monitorizacion=1
BSF	estados,1 ;an0
movlw	.2
movwf	contador_segundos
movlw .1
MOVWF carga_segundos 	
movwf	numero_de_segundos
movlw	.10
movwf umbral0

movlw	.25
movwf umbral1

movlw	.50
movwf umbral3


main

	goto main



ISR:
		BTFSC INTCON,T0IF
			GOTO	ISR_TMR0
			BTFSC	INTCON,INTF
				GOTO	ISR_RB0
				BTFSC	INTCON,RBIF
					GOTO	ISR_RB67
					BTFSC	PIR1,ADIF
						GOTO ISR_AD
							BTFSC	PIR1,RCIF
								GOTO	ISR_RECEPCION	
								BTFSC	PIR1,TXIF
									GOTO	ISR_TRANSMISION
										RETFIE

	
	ISR_TMR0:
				BCF  INTCON,T0IF
					DECFSZ	contador_segundos
							goto consumir_tiempo
							goto incrementar_segundos



consumir_tiempo:
			movlw .61
			movwf	TMR0
			RETFIE

incrementar_segundos:
				incf segundos,1
				decfsz numero_de_segundos
							GOTO reponer_tmr0
							goto convertir_canales

reponer_tmr0:

MOVLW .2
MOVWF contador_segundos
MOVLW .61
MOVWF TMR0
retfie


convertir_canales:
				BTFSC	estados,0
					goto ver_canal
					BTFSC	estados,0
						retfie
					goto ver_canal

ver_canal:
		btfsc estados,1
				goto muestrear_canal0
				btfsc estados,2
					goto muestrear_canal1
					btfsc	estados,3
						goto muestrear_canal3
						retfie

muestrear_canal0:
BCF estados,1
BSF estados,2 ; PREPARO EL MUESTREO DEL SIGUIENTE CANAL
BCF	ADCON0,CHS2
BCF	ADCON0,CHS1
BCF	ADCON0,CHS0
;METER NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
BSF	ADCON0,GO
movf 	carga_segundos,0
movwf 	numero_de_segundos
goto activar_tmr0




muestrear_canal1:
BCF estados,2
BSF estados,3 ; PREPARO EL MUESTREO DEL SIGUIENTE CANAL
BCF	ADCON0,CHS2
BCF	ADCON0,CHS1
BSF	ADCON0,CHS0
;METER NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
BSF	ADCON0,GO
movf 	carga_segundos,0
movwf 	numero_de_segundos
goto activar_tmr0






muestrear_canal3:
BCF estados,3
BSF estados,1 ; PREPARO EL MUESTREO DEL SIGUIENTE CANAL
BCF	ADCON0,CHS2
BSF	ADCON0,CHS1
BSF	ADCON0,CHS0
;METER NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
BSF	ADCON0,GO
movf 	carga_segundos,0
movwf 	numero_de_segundos
goto activar_tmr0


activar_tmr0:

MOVLW .2
MOVWF contador_segundos
MOVLW .61
MOVWF TMR0

RETFIE


ISR_AD: ;DEBO VER PRIMERO QUE CANAL HA SIDO EL QUE HA HECHO LA OPERACIÓN , PARA ELLO VOY A VER LOS CHS2,CHS1,CHS0
BCF PIR1,ADIF
BTFSC	ADCON0,CHS0
GOTO VERIFICAR_CH_1_3
GOTO CH_0_CONVERTIDO



VERIFICAR_CH_1_3:

BTFSC ADCON0,CHS1  
GOTO CH_3_CONVERTIDO
GOTO CH_1_CONVERTIDO




CH_0_CONVERTIDO: 
MOVF	 ADRESH,0
MOVWF 	canal0
RRF		canal0,1
RRF		canal0,1
BCF		canal0,7
BCF		canal0,6
movf	canal0,0
SUBWF	umbral0,0
		BTFSC	STATUS,C
			GOTO UMBRAL_MAYOR0;c=1
			GOTO UMBRAL_MENOR0 ;c=0


UMBRAL_MENOR0:

BSF	PORTB,RB1
GOTO interrupcion_76

UMBRAL_MAYOR0:

BCF	PORTB,RB1
			 
GOTO interrupcion_76






CH_1_CONVERTIDO:
MOVF	 ADRESH,0
MOVWF 	canal1
RRF		canal1,1
RRF		canal1,1
BCF		canal1,7
BCF		canal1,6
movf	canal1,0
SUBWF	umbral1,0
		BTFSC	STATUS,C
			GOTO UMBRAL_MAYOR1 ;C=1
			GOTO UMBRAL_MENOR1 ;C=0


UMBRAL_MENOR1:
BSF	PORTB,RB2
GOTO interrupcion_76

UMBRAL_MAYOR1:
BCF	PORTB,RB2
GOTO interrupcion_76
			 





CH_3_CONVERTIDO:
MOVF	 ADRESH,0
MOVWF 	canal3
RRF		canal3,1
RRF		canal3,1
BCF		canal3,7
BCF		canal3,6
movf	canal3,0

SUBWF	umbral3,0
		BTFSC	STATUS,C
			GOTO UMBRAL_MAYOR3	;C=1
			GOTO UMBRAL_MENOR3 ; C=0

UMBRAL_MENOR3:

BSF	PORTB,RB3
goto interrupcion_76

UMBRAL_MAYOR3:

BCF	PORTB,RB3
goto interrupcion_76






ISR_RB67:; tengo que ver si se ha ocurrido una interrupción tanto en el 6 o en el 7, independiente de si es en el 6 o 7, voy a hacer lo mismo
	call retardo_30ms
	MOVF PORTB,0
	BCF INTCON,RBIF
	XORWF	exPortb,0
	MOVWF	resXor
	MOVF	PORTB,0
	MOVWF	exPortb


				; lo primero es ver en que estado estoy para poder hacer una cosa u otra.Luego ver como esta rb76 y luego ver rb45

		
BTFSC	estados,0
	goto modo_motorizacion
	goto modo_ajuste_local



modo_ajuste_local:
			; PRIMERO SE DEBE ELIGIR QUE QUIERES MODIFICAR Y LUEGO PULSAR EL BOTON DE RB4 O RB5

		



		 BTFSC	PORTB,7
		goto verificar_6_local
		BTFSC	PORTB,6     
			goto modificar_umbral_1			;01	
			goto modificar_umbral_0			;00


verificar_6_local:

	BTFSC	PORTB,6 
	goto	modificar_tiempo;11
	goto	modificar_umbral_3;10


modificar_tiempo:

		BTFSC resXor,5
			goto isr_5
			BTFSC resXor,4
				goto isr_4
				retfie

isr_5:

BTFSC	PORTB,RB5
	GOTO	rb5_pulsado
	 RETFIE

isr_4:

			BTFSC	PORTB,RB4
				GOTO rb4_pulsado
					RETFIE


rb5_pulsado: ;incrementar el tiempo

			movf carga_segundos,0
			sublw .10
				BTFSC STATUS,Z	
					GOTO NO_INCREMENTAR_TOP_S
					GOTO SI_INCREMENTAR_TOP_S

NO_INCREMENTAR_TOP_S:

	MOVLW 	.10
	MOVWF	carga_segundos
	movwf 	numero_de_segundos
	movwf 	PORTC			;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	goto 	activar_tmr0



SI_INCREMENTAR_TOP_S:

	INCF	carga_segundos,1
	MOVF	carga_segundos,0
	movwf 	numero_de_segundos
	movwf 	PORTC			;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	goto 	activar_tmr0



rb4_pulsado: ;incrementar el tiempo

			movf carga_segundos,0
			sublw .1
				BTFSC STATUS,Z	
					GOTO NO_INCREMENTAR_DOWN_S
					GOTO SI_INCREMENTAR_DOWN_S
		


			
NO_INCREMENTAR_DOWN_S:

	MOVLW 	.1
	MOVWF	carga_segundos
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	movwf 	numero_de_segundos
	goto 	activar_tmr0

SI_INCREMENTAR_DOWN_S:

	DECF	carga_segundos,1
	MOVF	carga_segundos,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	movwf 	numero_de_segundos
	goto 	activar_tmr0




		










modificar_umbral_0:
	BTFSC	resXor,5
		GOTO  ISR_5_umbr_0
		BTFSC	resXor,4
			GOTO ISR_4_umbr_0
			RETFIE

ISR_5_umbr_0:
		BTFSC PORTB,5
				GOTO	 rb_5_umbr_0
				RETFIE

rb_5_umbr_0:

movlw .60
subwf umbral0,0
BTFSC STATUS,Z
	GOTO NO_INCREMENTAR_TOP_U0
	GOTO SI_INCREMENTAR_TOP_U0


NO_INCREMENTAR_TOP_U0:

	movlw	.60
	movwf	umbral0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0


		

SI_INCREMENTAR_TOP_U0;

	incf umbral0,1
	MOVF	umbral0,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0




ISR_4_umbr_0:	
		
		BTFSC PORTB,4
				GOTO	 rb_4_umbr_0
				RETFIE

rb_4_umbr_0:

movlw .4
subwf umbral0,0
BTFSC STATUS,Z
	GOTO NO_DECREMENTAR_DOWN_U0
	GOTO SI_DECREMENTAR_DOWN_U0


NO_DECREMENTAR_DOWN_U0:

	movlw	.4
	movwf umbral0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0


		

SI_DECREMENTAR_DOWN_U0:

	DECF umbral0,1
	MOVF	umbral0,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0




















modificar_umbral_1:


	BTFSC	resXor,5
		GOTO  ISR_5_umbr_1
		BTFSC	resXor,4
			GOTO ISR_4_umbr_1
			RETFIE

ISR_5_umbr_1:
			BTFSC PORTB,5
				GOTO	 rb_5_umbr_1
				RETFIE

rb_5_umbr_1:

movlw .60
subwf umbral1,0
BTFSC STATUS,Z
	GOTO NO_INCREMENTAR_TOP_U1
	GOTO SI_INCREMENTAR_TOP_U1


NO_INCREMENTAR_TOP_U1:

	movlw	.60
	movwf umbral1
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0


		

SI_INCREMENTAR_TOP_U1;

	incf umbral1,1
	MOVF	umbral1,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0





ISR_4_umbr_1:	
		
		BTFSC PORTB,4
				GOTO	 rb_4_umbr_1
				RETFIE

rb_4_umbr_1:

movlw .4
subwf umbral1,0
BTFSC STATUS,Z
	GOTO NO_DECREMENTAR_DOWN_U1
	GOTO SI_DECREMENTAR_DOWN_U1


NO_DECREMENTAR_DOWN_U1:

	movlw	.4
	movwf umbral1
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0


		

SI_DECREMENTAR_DOWN_U1:

	DECF umbral1,1
	MOVF	umbral1,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0










modificar_umbral_3:
	BTFSC	resXor,5
		GOTO  ISR_5_umbr_3
		BTFSC	resXor,4
			GOTO ISR_4_umbr_3
			RETFIE

ISR_5_umbr_3:
			BTFSC PORTB,5
				GOTO	 rb_5_umbr_3
				RETFIE

rb_5_umbr_3:

movlw .60
subwf umbral3,0
BTFSC STATUS,Z
	GOTO NO_INCREMENTAR_TOP_U3
	GOTO SI_INCREMENTAR_TOP_U3


NO_INCREMENTAR_TOP_U3:

	movlw	.60
	movwf	umbral3
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0


		

SI_INCREMENTAR_TOP_U3;

	incf umbral3,1
	movf	umbral3,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0





ISR_4_umbr_3:	
		
		BTFSC PORTB,4
				GOTO	 rb_4_umbr_3
				RETFIE

rb_4_umbr_3:

movlw .4
subwf umbral3,0
BTFSC STATUS,Z
	GOTO NO_DECREMENTAR_DOWN_U3
	GOTO SI_DECREMENTAR_DOWN_U3


NO_DECREMENTAR_DOWN_U3:

	movlw	.4
	movwf	umbral3
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0


		

SI_DECREMENTAR_DOWN_U3:

	DECF umbral3,1
	MOVF umbral3,0
	MOVWF	PORTC  ;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	GOTO activar_tmr0

  











modo_motorizacion:

	BTFSC resXor,7
		RETFIE
		BTFSC	resXor,6
			RETFIE
			interrupcion_76

	
interrupcion_76:

		BTFSC PORTB,7
			GOTO verificar_6
			BTFSC	 PORTB,6 
				GOTO	mostrar_canal_1		; 01
				GOTO	mostrar_canal_0		;00

verificar_6:
		BTFSC PORTB,6
	GOTO  tiempo_conversion		;11
	GOTO mostrar_canal_3			;10




mostrar_canal_1:
movf canal1,0
movwf PORTC
RETFIE
											
						
mostrar_canal_0:
movf canal0,0
movwf PORTC
RETFIE



mostrar_canal_3:
movf canal3,0
movwf PORTC
RETFIE




tiempo_conversion:

movf	carga_segundos,0
movwf PORTC
retfie 

ISR_RB0:; una vez aquí tienes que saber de qué estado vienes
		;para poder saber a que estado vas
callretardo_30ms
BCF INTCON,INTF
BTFSC estados,0
	goto ajuste_local
	goto monitorizacion



monitorizacion: ;DEBO ACTIVAR EL TMR0 y volver al bucle
BSF	estados,0
BSF STATUS,RP0
BCF	OPTION_REG,T0CS
BCF STATUS,RP0
RETFIE


ajuste_local:;DEBO ACTIVAR EL TMRO Y volver al bucle, ya veré que hago cuando salte la interrupcion RB76
BCF	estados,0
;desactivo el tmr0 para no seguir haciendo lo mismo que se hace en el monitorizacion
BSF STATUS,RP0
BSF	OPTION_REG,T0CS
BCF STATUS,RP0
bcf	PORTB,1
bcf	PORTB,2
bcf	PORTB,3
RETFIE
		

ISR_RECEPCION:

		MOVF 	puntero_recepcion,0
		MOVWF 	FSR
		MOVF 	RCREG,0
		MOVWF	INDF	

		
		DECFSZ long_recepcion,1
				GOTO recibir_datos
				GOTO fin_recepcion


recibir_datos:
		incf	puntero_recepcion,1		
		RETFIE


fin_recepcion:
		movlw 0x31
		movwf	puntero_recepcion
		movlw	.5
		movwf	long_recepcion

		;veamos que he recibido

		movlw  	'c'
		subwf	DATO1,0
		BTFSC	STATUS,Z
			GOTO c_recibido
			GOTO	enviar_not_recognized

c_recibido:
		movlw	'1'
		subwf	DATO2,0
		BTFSC	STATUS,Z
			GOTO	c1_recibido
			GOTO	enviar_not_recognized


c1_recibido:
		movlw	's'
		subwf	DATO3,0
		BTFSC	STATUS,Z
			GOTO c1s_recibido
				movlw	'u'
					subwf	DATO3,0
					BTFSC	STATUS,Z
						GOTO	c1u_recibido
							movlw	'c'
								subwf	DATO3,0
								BTFSC	STATUS,Z
									GOTO	c1c_recibido
									GOTO enviar_command_not_found



c1s_recibido:
		
		movlw	 't'
		subwf	DATO4,0
		BTFSC 	STATUS,Z
			goto ver_D5
			GOTO enviar_command_not_found


ver_D5:
		
		movf 		DATO5,0
		sublw		.1
		BTFSC		STATUS,Z
		GOTO 		actualizar_tiempo_D5
		BTFSC		STATUS,C
		GOTO 		enviar_parameter_not_valid		; DATO5<1 NO INTERESA	
		movf		DATO5,0							; DATO5>1,  INTERESA
		sublw		.10
		BTFSC		STATUS,Z
		GOTO		actualizar_tiempo_D5
		BTFSC		STATUS,C
		GOTO		enviar_parameter_not_valid			;DATO5 POSITIVO, NO INTERESA
		GOTO		actualizar_tiempo_D5			;DATO5 NEGATIVO,  INTERESA


actualizar_tiempo_D5:
			
	MOVF 	DATO5,0
	MOVWF	carga_segundos
	MOVWF	PORTC  					;HAY QUE MUESTREAR LOS VALORES QUE CAMBIAS EN PORTC
	MOVWF 	numero_de_segundos
	goto 	activar_tmr0





enviar_not_recognized:

	movf	DATO1,0
	movwf 	0x40

	movf	DATO2,0
	movwf	0x41

	movf	DATO3,0
	movwf	0x42
	
	movf	DATO4,0
	movwf	0x43

	movf	DATO5,0
	movwf	0x44

	movlw	20
	movwf	0x45


	MOVLW 	'N'
	MOVWF	0X46

	MOVLW 	'O'
	MOVWF	0X47


	MOVLW 	'T'
	MOVWF	0X48


	MOVLW 	20
	MOVWF	0X49

	MOVLW 	'R'
	MOVWF	0X4A

	MOVLW 	'E'
	MOVWF	0X4B


	MOVLW 	'C'
	MOVWF	0X4C	
	


	MOVLW 	'O'
	MOVWF	0X4D

	MOVLW 	'G'
	MOVWF	0X4E


	MOVLW 	'N'
	MOVWF	0X4F	



	MOVLW 	'I'
	MOVWF	0X50


	MOVLW 	'Z'
	MOVWF	0X51

	MOVLW 	'E'
	MOVWF	0X52

	MOVLW 	'D'
	MOVWF	0X53

	MOVLW .10
	MOVWF	0X54
	
	MOVLW .12
	MOVWF	0X55
	

	movlw 	0x40
	movwf 	puntero_transmision
	movlw	.21
	movwf	long_transmision
	
	call activa_TXIE
	RETFIE











enviar_parameter_not_valid:
		
	MOVLW 	'P'
	MOVWF	0X40

	MOVLW 	'A'
	MOVWF	0X41


	MOVLW 	'R'
	MOVWF	0X42


	MOVLW 	'A'
	MOVWF	0X43

	MOVLW 	'M'
	MOVWF	0X44

	MOVLW 	'E'
	MOVWF	0X45


	MOVLW 	'T'
	MOVWF	0X46	
	
	
	MOVLW 	'E'
	MOVWF	0X47


	MOVLW 	'R'
	MOVWF	0X48

	MOVLW 	20
	MOVWF	0X49

	MOVLW 	'N'
	MOVWF	0X4A


	MOVLW 	'O'
	MOVWF	0X4B	



	MOVLW 	'T'
	MOVWF	0X4C


	MOVLW 	 20
	MOVWF	0X4D

	MOVLW 	'V'
	MOVWF	0X4E

	MOVLW 	'A'
	MOVWF	0X4F


	MOVLW 	'L'
	MOVWF	0X50	


	MOVLW 	'I'
	MOVWF	0X51


	MOVLW 	'D'
	MOVWF	0X52

	MOVLW .10
	MOVWF	0X53
	
	MOVLW .12
	MOVWF	0X54
	

	movlw 	0x40
	movwf 	puntero_transmision
	movlw	.21
	movwf	long_transmision
	
	call activa_TXIE
	RETFIE






enviar_command_not_found:


	MOVLW 	'C'
	MOVWF	0X40

	MOVLW 	'O'
	MOVWF	0X41


	MOVLW 	'M'
	MOVWF	0X42


	MOVLW 	'M'
	MOVWF	0X43

	MOVLW 	'A'
	MOVWF	0X44

	MOVLW 	'N'
	MOVWF	0X45


	MOVLW 	'D'
	MOVWF	0X46	
	


	MOVLW 	20
	MOVWF	0X47

	MOVLW 	'N'
	MOVWF	0X48


	MOVLW 	'O'
	MOVWF	0X49	



	MOVLW 	'T'
	MOVWF	0X4A


	MOVLW 	20
	MOVWF	0X4B

	MOVLW 	'F'
	MOVWF	0X4C

	MOVLW 	'O'
	MOVWF	0X4D


	MOVLW 	'U'
	MOVWF	0X4E	


	MOVLW 	'N'
	MOVWF	0X4F


	MOVLW 	'D'
	MOVWF	0X50

	MOVLW .10
	MOVWF	0X51
	
	MOVLW .12
	MOVWF	0X52
	

	movlw 	0x40
	movwf 	puntero_transmision
	movlw	.19
	movwf	long_transmision
	
	call activa_TXIE
	RETFIE





c1c_recibido:

	movlw	 'h'
	subwf	DATO4,0
	btfsc	STATUS,Z
		GOTO	enviar_informacion_canal
		GOTO	enviar_command_not_found

	




enviar_informacion_canal:
			
		movlw		.0
		subwf		DATO5,0
		btfsc		STATUS,Z
			GOTO	enviar_canal0_remoto
			movlw	.1
			subwf	DATO5,0
				btfsc	STATUS,Z
					GOTO	enviar_canal1_remoto
					movlw	.3
					subwf	DATO5,0
						btfsc	STATUS,Z
							GOTO	enviar_canal3_remoto
								GOTO enviar_command_not_found




enviar_canal0_remoto:
	BCF	estados,6	;canal3
	BCF estados,5	;canal1
	BSF	estados,4	;canal0

	retfie

enviar_canal1_remoto:

	BCF	estados,6	;canal3
	BSF estados,5	;canal1
	BCF	estados,4	;canal0
	retfie


enviar_canal3_remoto:

	BSF	estados,6	;canal3
	BCF estados,5	;canal1
	BCF	estados,4	;canal0
	retfie
								



c1u_recibido:
			movf	DATO4,0
			sublw  .0
			BTFSC	STATUS,Z
				goto actualizar_canal0_D5
				movf	DATO4,0
				sublw	.1
				BTFSC	STATUS,Z
					goto	actualizar_canal1_D5
						movf	DATO4,0
						sublw	.3
						BTFSC	STATUS,Z	
							goto actualizar_canal3_D5
							goto enviar_command_not_found
					
								
			
				
	
			


actualizar_canal0_D5:
	movf	DATO5,0
	movwf	umbral0	
	retfie

actualizar_canal1_D5:
	movf	DATO5,0
	movwf	umbral1	
	retfie

actualizar_canal3_D5:
	movf	DATO5,0
	movwf	umbral3	
	retfie




activa_TXIE:
		BSF STATUS,RP0
		BSF	PIE1,TXIE
		BCF	STATUS,RP0
	return














ISR_TRANSMISION:
		
	movf	puntero_transmision,0
	movwf	FSR
	MOVF	INDF,0
	movwf 	TXREG
	
	DECFSZ long_transmision,1
	GOTO seguir_transmitiendo
	GOTO fin_transmision

seguir_transmitiendo:
	incf puntero_transmision,1
	retfie


fin_transmision:
	;DESACTIVO EL ENVIO
BSF STATUS,RP0
BCF	PIE1,TXIE
BCF STATUS,RP0
RETFIE



enviar_resultado_canal0:

	movf	DATO1,0
	movwf 	0x40

	movf	DATO2,0
	movwf	0x41

	movf	DATO3,0
	movwf	0x42
	
	movf	DATO4,0
	movwf	0x43

	movlw	'0'
	movwf	0x44
	
	movf	canal0,0
	movwf	0x45
	

return

enviar_resultado_canal1:

	movf	DATO1,0
	movwf 	0x40

	movf	DATO2,0
	movwf	0x41

	movf	DATO3,0
	movwf	0x42
	
	movf	DATO4,0
	movwf	0x43

	movlw	'1'
	movwf	0x44
	
	movf	canal1,0
	movwf	0x45

return


enviar_resultado_canal3:

	movf	DATO1,0
	movwf 	0x40

	movf	DATO2,0
	movwf	0x41

	movf	DATO3,0
	movwf	0x42
	
	movf	DATO4,0
	movwf	0x43

	movlw	'3'
	movwf	0x44
	
	movf	canal3,0
	movwf	0x45

return




retardo_30ms
movlw .184
movwf CONT2
bucle_retardo
movlw .53
movwf CONT1
ciclo1
decfsz CONT1,1
goto ciclo1
decfsz CONT2,1
goto bucle_retardo
nop
nop
nop
return


	

END