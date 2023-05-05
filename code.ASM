;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	CALC.ASM	MPB	Ver 1.0		28-8-05
;
;	Simple calculator 
;	Single digit input, two digit results
;	Integer handling only  
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PROCESSOR 16F877
;	Clock = XT 4MHz, standard fuse settings
	__CONFIG 0x3731

;	LABEL EQUATES	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INCLUDE "P16F877A.INC"	


Cursor	EQU 28
Timer	EQU 39
Char	EQU	30	; Display character code
Char1	EQU 41
Char2	EQU 42
Char3	EQU 43
Char4	EQU 44
Char5	EQU 45
Index	EQU 46
Characters EQU 48
Current_char EQU 47

RS	EQU	1	; Register select output bit
E	EQU	2	; Display data strobe


; Program begins ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	0		; Default start address 
	NOP			; required for ICD mode

	BANKSEL	TRISC		; Select bank 1
	MOVLW	B'11110000'	; Keypad direction code
	MOVWF	TRISC		;  
	CLRF	TRISD		; Display port is output
	MOVLW B'11111111' ;port b as input
	MOVWF TRISB

	BANKSEL PORTC		; Select bank 0
	MOVLW	0FF		; 
	MOVWF	PORTC		; Set keypad outputs high
	CLRF	PORTD		; Clear display outputs
	GOTO	start		; Jump to main program


; MAIN LOOP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________________________________________Welcome____________________________________________________________

start	CALL	inid		; Initialise the display
		MOVLW	0x80		; position to home cursor
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
		BSF Select,RS
		movlw 'E' ; Load the character 'E' into the W register
		call send ; Send the character to the LCD
		movlw 'n' ; Load the character 'n' into the W register
		call send ; Send the character to the LCD
		movlw 't' ; Load the character 't' into the W register
		call send ; Send the character to the LCD
		movlw 'e' ; Load the character 'e' into the W register
		call send ; Send the character to the LCD
		movlw 'r' ; Load the character 'r' into the W register
		call send ; Send the character to the LCD
		movlw ' ' ; Load the character ' ' into the W register
		call send ; Send the character to the LCD
		movlw 'S' ; Load the character 'S' into the W register
		call send ; Send the character to the LCD
		movlw 't' ; Load the character 't' into the W register
		call send ; Send the character to the LCD
		movlw 'r' ; Load the character 'r' into the W register
		call send ; Send the character to the LCD
		movlw 'i' ; Load the character 'i' into the W register
		call send ; Send the character to the LCD
		movlw 'n' ; Load the character 'n' into the W register
		call send ; Send the character to the LCD
		movlw 'g' ; Load the character 'g' into the W register
		call send ; Send the character to the LCD
		

		CLRW	Char		; ASCII = 0
		CLRW	Kval		; Key value = 0
		CLRW	DFlag		; Digit flags = 0
		;___________________init vars_________________________
		movlw 0 	;initialize index 
		movwf Index
		movlw 0  	;initialize 
		movwf Characters
		MOVLW 0x0 	;initialize timer
		MOVWF Timer
		MOVLW 41 ;initialize pointer
		MOVWF FSR ;to RAM

	MOVLW 0x20 	;initialize timer
	MOVWF Char1
	MOVLW 0x20 	;initialize timer
	MOVWF Char2
	MOVLW 0x20 	;initialize timer
	MOVWF Char3
	MOVLW 0x20 	;initialize timer
	MOVWF Char4
	MOVLW 0x20 	;initialize timer
	MOVWF Char5
		;_______________________________________________________________________ENTER STRING____________________________________________________________
pRoutine MOVLW 0xC0 ;move cursor to second line
		BCF Select,RS ; command
		call send
		MOVLW 0x0F;blinking command mode
		call send

		BSF Select,RS ; data mode

		; Load the value 0x41 (A) to W and send it to LCD
    	movlw 0x41
  		movwf Current_char
		call send

		BCF Select,RS;go back to command mode
		MOVLW 0x10;moves cursor back 
		call send
	

;___________________________________________




buttonNotPressed incf Timer, 1	;increment the timer
		MOVLW	D'100'		; Load count for 100ms delay
		CALL	xms

		movlw 10
		xorwf Timer, W  ;check if timer reached limit
		btfsc STATUS, Z ; when res is zero Z = 1
		call incCursor  ; do this when equal 

		btfsc PORTB, 0
		goto buttonNotPressed
		
		movlw 0x0
		movwf Timer;reset timer

		movlw 'Z'
		xorwf Current_char, W ;check if character is Z
		btfss STATUS, Z 
		goto printNext ;do this when not equal
	
	;char before ' '
    	movlw 0x1F
    	movwf Current_char
		goto printNext	;print space

;__________________________________________________________INC char_______________________________________
printNext movfw Current_char
    	addlw 0x1
    	movwf Current_char
		BSF Select,RS;write mode
		call send
		
	;return cursor left
		BCF Select,RS	;go back to command mode
		MOVLW 0x10
		call send
	
	;200ms delay
		MOVLW	D'200'		
		CALL	xms

		movlw ' '
		xorwf Current_char, W ;check if character is ' '
		btfss STATUS, Z
		goto buttonNotPressed ;do this when not equal

		movlw 0x40
		movwf Current_char
		goto buttonNotPressed
;_______________________________________________________________________INC Cursor____________________________________________________________
;save current char
incCursor movlw 0x40
		xorwf Current_char, W  ;check if ' '
		btfsc STATUS, Z ; when res is zero Z = 1
		goto test_off  ; do this when equal  

		movfw Current_char
		movwf INDF
		INCF FSR,1 	;inc pointer
		incf Index,1;inc index to save characterss
		
	;move cursor to the right
		BCF Select,RS
		movlw 0x14	
		call send

	;reset timer
		movlw 0x0
		movwf Timer

	;reset char to A
		movlw '@'
		movwf Current_char
	
	;check if 5 chars reached   
		movlw 5
		xorwf Index, W ;check if characters reached 5
		btfsc STATUS, Z
		call test_off 	;do this when equal
		goto printNext
		return

;_______________________________________________________________________Turn off desplay____________________________________________________________
test_off movlw 0x08
		BCF Select,RS
		call send
		MOVLW	D'4000'		; Load count for 100ms delay
		CALL	xms
		MOVLW	D'4000'		; Load count for 100ms delay
		CALL	xms
		MOVLW	D'4000'		; Load count for 100ms delay
		CALL	xms
		MOVLW	D'4000'		; Load count for 100ms delay
		CALL	xms
		MOVLW	D'4000'		; Load count for 100ms delay
		CALL	xms
		MOVLW	D'4000'		; Load count for 100ms delay
		CALL	xms


;_____________________________________________________^
	;Clear LCD and go to beginning of 1st row
shift_screen	MOVLW	0x01		; clear
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code
		MOVLW	0x80		; position to home cursor
		CALL	send		; and send code


		BSF Select,RS ;data mode
		MOVLW 45 ;initialize pointer
		MOVWF FSR ;to RAM
		
printt  movfw INDF
		call send
		DECF FSR,1 ;inc pointer
	
	
		movlw 40
		xorwf FSR, W  
		btfss STATUS, Z ; when res is zero Z = 1
		GOTO printt ;	do this when not equal

		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left

		BCF Select,RS
		movlw 0x0E
		call send

;_______________________________________________________
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		call shift_once
		



;___________________________________________---BLOCK # 1---_____________________________
		btfss PORTB, 0
		goto start
	;clear
		MOVLW	0x01		; clear
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code


	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8C    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 45 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8D    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 44 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8E    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 43 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8F    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 42 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot 
		BCF	Select,RS	; command mode		
  	 	movlw   0xCF    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 41 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
;_______________________________________________________________
;___________________________________________---BLOCK # 2---_____________________________
		btfss PORTB, 0
		goto start
	;clear
		MOVLW	0x01		; clear
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code


	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8D    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 45 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8E    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 44 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8F    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 43 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCF    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 42 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot 
		BCF	Select,RS	; command mode		
  	 	movlw   0xCE    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 41 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
;_______________________________________________________________

;___________________________________________---BLOCK # 3---_____________________________
		btfss PORTB, 0
		goto start
	;clear
		MOVLW	0x01		; clear
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code


	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8E    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 45 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8F    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 44 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCF    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 43 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCE    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 42 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot 
		BCF	Select,RS	; command mode		
  	 	movlw   0xCD    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 41 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
;_______________________________________________________________
;___________________________________________---BLOCK # 4---_____________________________
		btfss PORTB, 0
		goto start
	;clear
		MOVLW	0x01		; clear
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code


	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0x8F    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 45 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCF    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 44 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCE    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 43 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCD   ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 42 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot 
		BCF	Select,RS	; command mode		
  	 	movlw   0xCC    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 41 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
;_______________________________________________________________

;___________________________________________---BLOCK # 5---_____________________________
		btfss PORTB, 0
		goto start
	;clear
		MOVLW	0x01		; clear
		BCF	Select,RS	; Select command mode
		CALL	send		; and send code


	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCF    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 45 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCE    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 44 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCD    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 43 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot
		BCF	Select,RS	; command mode		
  	 	movlw   0xCC   ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 42 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

	;choose slot 
		BCF	Select,RS	; command mode		
  	 	movlw   0xCB    ; Address for slot
    	call    send
	;print char
		BSF Select,RS
		MOVLW 41 ;initialize pointer
		MOVWF FSR ;to RAM
		movfw INDF
		call send

		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
;_______________________________________________________________



;___________
;ffg goto ffg

		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left
		call shift_once_left

		movlw 0x08
		BCF Select,RS
		call send

		;MOVLW	0x80		; position to home cursor
		;BCF	Select,RS	; Select command mode
		;CALL	send
		goto shift_screen
		
shift_once btfss PORTB, 0
		goto start
		movlw 0x1C
		BCF	Select,RS	; Select command mode
		CALL	send
		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
		return

shift_once_left btfss PORTB, 0
		goto start
		movlw 0x18
		BCF	Select,RS	; Select command mode
		CALL	send
		MOVLW	D'500'		; Load count for 100ms delay
		CALL	xms
		return

; Include LCD driver routine
	
	INCLUDE	"LCDIS.INC"

	END	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;