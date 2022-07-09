; Timothy Mui
;
; https://github.com/theblankness
;
; Dec 2, 2013
;
; Description: This program takes a 10-digit binary number and outputs the number converted to decimal and converted to duotrigesimal. 

	org 100h

section .text

; This label starts the program and initializes the registers for prompt.
start:
	mov bx, inputPrompt ; Point BX to inputPrompt
	jmp prompt ; Go to prompt

; This label displays the opening prompt alerting the user to input a 10 digit binary number.
prompt:
	mov dl, [bx] ; Move BX value to DL for current character
	inc bx ; Increment BX
	cmp dl, 0 ; If DL is 0, go to inputInit
	je inputInit 
	mov ah, 06h ; Service for output
	int 21h ; Output bx
	jmp prompt ; Loop prompt

; This label prepares the registers for taking user input.
inputInit:
	mov bx, userInput ; Point BX to userInput
	mov cx, 0 ; Loop Counter
	jmp input ; Jump to input

; This label takes input from the user in the form of 10 binary digits each stored in 1 byte as a string.
input:
	mov ah, 00h ;Service for input
	int 16h ;Read char into AL
	
	cmp al, 13 ;Check for return
	je digitCheck ; When return is entered, go to digitCheck
	
	cmp al, 30h ; Check for Binary (0)
	jl reset ; Reset if it is less than 30h (0 in ASCII)
	
	cmp al, 31h ; Check for Binary (1)
	jg reset ; Reset if it is greater than 31h (1 in ASCII)
	
	sub al, 30h ;String to Binary digit (1 or 0) stored in a byte
	mov [bx], al ; Store character
	
	add al, 30h ; AL back to ASCII for display
	mov dl, al ; Move the inputted character to DL
	mov ah, 06h ; Service for output
	int 21h ; Output inputted value	
	
	inc bx ; move next character of bx
	inc cx ; count

	jmp input ; loop the input
	
; This label re-initializes the program if an illegal character is inputted.
reset:
	;New Line
	mov ah, 06h
	mov dl, 0ah
	int 21h
	
	mov bx, 0 ; Reset BX to zero
	jmp start ; Jump to beginning of program

; This label checks if the user inputted value is 10 digits long.
digitCheck:
	cmp cx, 10 ;Check if 10 digits
	je toDecimal1Init ; If 10 digits, go toBinaryInit
	jmp reset ; Jump to reset if not 10 digit long

; This label prepares the registers for the second shift. 2 shifts are required as different registers must be used.
toDecimal1Init:
	;Null Termination
	inc bx
	mov [bx], byte 0
	
	sub ax, ax  ;Set AX to 0
	mov bx, userInput  ;Move userInput to DX
	mov cl, 9  ;Set CL to 9
	sub dx, dx ; DX = 0
	jmp toDecimal1 ; Go toDecimal1

; This label shifts the upper 2 bits of the binary digit (required because of size, byte vs. word).
toDecimal1:
	mov dx, [bx] ; Move BX value to DX for current character
	shl dx, cl  ; Shift BX to correspond with place
	add ax, dx  ;Add DX and AX
	inc bx   ;Point DX to the next value
	
	dec cl   ;Decrement CL 
	
	cmp cl, 7  ;If CL is 7, move to part 2 (with smaller register)
	je toDecimal2Init ; Proceed to toDecimal2Init
	
	jmp toDecimal1 ; Loop toDecimal1

; This label prepares the registers for the second shift.
toDecimal2Init:
	sub dx, dx ; Reset DX
	jmp toDecimal2 ; Go toDecimal2

; This label shifts the lower 8 bits of the binary digit (required because of size, byte vs. word)
toDecimal2:
	mov dl, [bx] ; Move BX value to DL for current character
	shl dl, cl  ;Shift BX to correspond with place
	add ax, dx  ;Add DX to AX
	inc bx   ;Point DX to the next value
	
	cmp cl, 0  ;If CL is 0, go to decimalToStringInit
	je decimalToStringInit; Proceed to decimalToStringInit
	
	dec cl   ;Decrement CL. 
	
	jmp toDecimal2 ; Loop toDecimal

; This label initializes registers for decimalToString
decimalToStringInit:
	mov [number], ax ; Store AX into decimal
	mov bx, decOut ; Point decOut to BX
	sub dx, dx ; DX = 0
	
	jmp decimalToString ; Proceed to displayInit

; This label converts the number to a string containing the decimal
decimalToString:	
	mov cx, 1000 ; Divide AX to get the digit
	div cx
	add al, 30h ; To ASCII
	mov [bx], al ; Move AL to Output (BX)
	inc bx ; Point to next number
	mov ax, dx ; Move remainder to AX
	sub dx, dx ; Clear DX
	
	mov cx, 100 ; Divide AX to get the digit
	div cx
	add al, 30h ; To ASCII
	mov [bx], al ; Move AL to Output (BX)
	inc bx ; Point to next number
	mov ax, dx ; Move remainder to AX
	sub dx, dx ; Clear DX
	
	mov cx, 10 ; Divide AX to get the digit
	div cx
	add al, 30h
	mov [bx], al
	inc bx
	
	add dl, 30h
	mov [bx], dl ; Move remainder to AX
	
	jmp displayDecInit ; Go to displayDecInit

; This label initializes registers for displayDec	
displayDecInit:
	mov ah, 02h ;Move 2 to AH for the output service
	mov dl, 0ah ; Move 10 to DL
	int 21h ; Output DH
	mov dl, 0dh; Move 13 to DL
	int 21h ; Output DH
	
	mov bx, decOut ; To be displayed
	jmp displayDec ; Go to displayDec
	
; This label displays the number as a decimal
displayDec:
	mov dl, [bx] ; Move BX value to DL for current character
	
	inc bx ; Increment BX
	
	cmp dl, 0 ; If end of string (Null)
	je toDuotrigInit ; Jump to quitInit
	
	mov ah, 02h ; Output service
	int 21h ; Output
	jmp displayDec ; Loop of displayDec

; This label initializes registers for the duotrigesimal conversion
toDuotrigInit:
	mov ax, [number] ; Point number to AX
	mov bx, duoOut ; Point duoOut to BX
	mov cx, 32  ; Move 32 to CX
	
	jmp toDuotrig1 ; Jump to toDuotrig 1

; This label converts the first digit of the duotrigesimal number
toDuotrig1:
	div cx ; Divide CX by AX
	cmp ax , 9 
	jle duotrigNum1 ; If AX is less than or equal to 9, go to Num
	jg duotrigChar1 ; If AX is greater than 9, go to Char

; This label runs if the first digit should be a number (0-9)
duotrigNum1:
	add ax , 30h ; Add 30h for numbers (Convert to ASCII value)
	mov [bx], ax ; Move AX to BX for storage
	
	inc bx ; Increment BX
	
	jmp toDuotrig2 ; Go toDuotrig2

; This label runs if the first digit should be a character (A-V)
duotrigChar1:
	add ax , 37h ; Add 37h to AX to get the corresponding letter (ASCII)
	mov [bx], ax ; Move AX to BX for storage
	
	inc bx ; Increment BX
	
	jmp toDuotrig2 ; Go toDuotrig2

; This label converts the second digit of the duotrigesimal number
toDuotrig2:
	mov ax, dx ; Move remainder to AX
	
	cmp ax , 9 
	jle duotrigNum2 ; If AX is less than or equal to 9, go to Num
	jg duotrigChar2 ; If AX is greater than 9, go to Char

; This label runs if the second digit should be a number (0-9)
duotrigNum2:
	add ax , 30h ; Add 30h for numbers (Convert to ASCII value)
	mov [bx], ax ; Move AX to BX for storage

	; Null Termination
	inc bx 
	mov [bx], byte 0
	
	jmp displayDuoInit ; Go to displayDuoInit

; This label runs if the second digit should be a character (A-V)
duotrigChar2:
	add ax , 37h ; Add 37h to AX to get the corresponding letter (ASCII)
	mov [bx], ax ; Move AX to BX for storage

	; Null Termination
	inc bx 
	mov [bx], byte 0
	
	jmp displayDuoInit ; Go to displayDuoInit
	
; This label initializes registers for displayDuo
displayDuoInit:
	mov ah, 02h ;Move 2 to AH for the output service
	mov dl, 0ah ; Move 10 to DL
	int 21h ; Output DH
	mov dl, 0dh; Move 13 to DL
	int 21h ; Output DH
	
	mov bx, duoOut ; To be displayed
	jmp displayDuo ; Goes to displayDuo

; This label displays the duotrigesimal number	
displayDuo:
	mov dl, [bx] ; Move BX value to DL for current character
	
	inc bx ; Increment BX
	
	cmp dl, 0 ; If end of string (Null)
	je quitMsgInit ; Jump to quitMsgInit
	
	mov ah, 02h
	int 21h
	jmp displayDuo ; Loop of displayDuo

; This label initializes the registers for quitMsg.
quitMsgInit:
	mov bx, quitPrompt ; Point quit message
	jmp quitMsg ; Go to quitMsg
	
; This label alerts the user to quit by pressing enter
quitMsg:
	mov dl, [bx] ; Move BX value to DL for current character
	inc bx ; Increment BX
	cmp dl, 0 ; If DL is 0, go to inputInit
	je quitInit ; Go to quitInit
	mov ah, 06h ; Service for output
	int 21h ; Output bx
	jmp quitMsg ; Loop prompt

; This label waits for the user to press enter before proceeding to closing the window	
quitInit:
	mov ah, 00h ;Service for input
	int 16h ;Read char into AL
	
	cmp al, 13 ;Check for return
	je quit ; Go to quit
	jmp quitInit ; Looping quit initializer
	
; This label ends the program (closes window)
quit:
	int 20h ;Exit program

; Variable Declarations 
section .data
	inputPrompt db "Please enter a 10 binary digit number.",10,13,0 ; Variable for the first input message
	quitPrompt db 10,13,"Please press enter to quit.",10,13,0 ; Variable for the quit message
	userInput TIMES 11 db 0 ; Variable to contain the user input
	number dw 0 ; Variable to contain the number from the input after conversion
	decOut TIMES 5 dw 0 ; Variable output for the decimal number as a string
	duoOut TIMES 2 db 0 ; Variable output for the duotrigesimal number as a string
	
