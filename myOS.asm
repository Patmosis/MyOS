	BITS 16

; Starting procedure
start:
	mov ax, 07C0h						; Set up 4K stack space after this bootloader
	add ax, 288							; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096

	mov ax, 07C0h						; Set data segment to where we're loaded
	mov ds, ax

	call clear_screen   		; Call clear_screen routine

	; Set background and text color
	mov ah, 06h							; Function to clear screen/scroll screen up ; used to set background and text default colors
	mov al, 0								; Number of lines to scroll up
	mov cx, 0								; Starting row/column coordinates (top left here)
	mov dh, 79							; Ending row coordinate
	mov dl, 79							; Ending column coordinate
	mov bh, 70h        			; Colors: 7 = white background, 0 = black text
	int 10h

	; Print welcome message
	mov bl, 74h      				; Set text color: red
	mov si, welcome_message	; Put string position into SI
	call print_string				; Print string

	call new_line						; Move cursor to next line


; Main loop of the program
session:
	; Print question
	mov bl, 71h							; Set text color: blue
	mov si, question				; Put string position into SI
	call print_string				; Prints string
	call new_line  					; Move cursor to next line

	call initiate_answer

	; Wait for user answer
	mov bx, 0h							; bx contains position of last added character in answer
	call read_input					; Read input from user
	call new_line						; Move cursor to next line

	; Print user answer
	mov bl, 70h							; Set text color: back
	mov si, you_want				; Prepare sentence to be printed
	call print_string				; Print string
	mov si, answer					; Prepare answer to be printed
	call print_string				; Print string
	call new_line  					; Move cursor to next line

	jmp session							; Jump here - infinite loop!


; Clear the screen
clear_screen:
	mov ax, 0003h						; Set video mode
	int 10h
	ret


; Print a string on the screen
print_string:
	; Loop printing a character for each iteration
	.repeat:
		mov ah, 09h					; Function to write a character
		mov cx, 1						; Number of time the character must be writter = 1
		mov bh, 0						; Page number = 0
		lodsb								; Get character from string (load what is in si in al)
		cmp al, 0						; If char is zero
			je done						;      end of string
		int 10h							; Otherwise, print it
		jmp .move_cursor

	; Add one column to the position of the cursor
	.move_cursor:
		mov ah, 03h					; Function to get cursor position
		int 10h							; Get cursor position in dl = columns and dh = rows
		mov ah, 02h					; Function to set cursor position
		inc dl							; Move cursor of one column
		int 10h							; Move cursor
		jmp .repeat					; Jump to writing next character

; Go where program was interrupted
done:
	ret


; Move cursor to next line
new_line:
	mov ah, 0eh   			; Print character function
	mov al, 0x0a				; \n
	int 10h      	     	; Print character
	mov al, 0dh					; \r
	int 10h							; Print character
	ret


; Read input from user, stop when ENTER is pressed
read_input:
	mov ah, 0h					; Read character from keyboard function
	int 16h							; Read character
	cmp al, 0Dh					; If read character is ENTER:
		je done						;				end of reading input
	mov [answer+bx], al	; Copy read character in answer
	mov ah, 0Eh					; Write character function
	int 10h							; Write character
	inc bx							; Increment of character to be added in answer
	jmp read_input			; Loop


; Initiate answer with zeros, as a "null string"
initiate_answer:
	mov bx, 0h						; Position of the character to be replaced by 0
	mov al, 0h						; Store 0h in register to replace characters of answer
	; Loop
	.repeat:
		cmp bx, 32h					; If current character is the 50th (50d = 32h)
			je done						;				end of initialization
		mov [answer+bx], al	; Replace answer's character with 0h
		inc bx							; Increment bx to target next character
		jmp .repeat


.data:
	welcome_message db 'Welcome on my OS.', 0
	question db 'What do you want to do?', 0
	you_want db 'So you want to: ', 0

.bss:
	answer times 50 db 0, 0


times 510-($-$$) db 0		; Pad remainder of boot sector with zeros
dw 0xAA55								; The standard PC boot signature
