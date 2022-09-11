[bits 16]
[org 0x7c00]

; Initialize registers
xor ax, ax
mov ds, ax
mov es, ax
mov bx, 0x8000

call boot

; Print al register
print_al:
	mov ah, 0x0e ; TTY output
	mov bh, 0x00 ; Page 0
	mov bl, 0x07 ; Color: Light grey on black background
	int 0x10

	ret

; Call print_al on all characters in si
; si must be null terminated
print_bytes_si:
	mov cl, 0 ; Start with iteration 0 - equivalent of int i = 0
print_bytes_si_loop:
	lodsb                  ; Load next characet of si into al
	call print_al

	inc cl

	cmp cl, ch
	jb print_bytes_si_loop

	ret

; Main
boot:
	; Clear the screen
	mov ah, 0x06
	mov al, 0x00
	mov bh, 0x07
	mov ch, 0x00
	mov cl, 0x00
	mov dh, 0xff
	mov dl, 0xff
	int 0x10

	; Move cursor to 0, 0 on page 0
	mov ah, 0x02
	mov bh, 0           ; Page
	mov dh, 0           ; Row
	mov dl, 0           ; Column
	int 0x10

	mov ch, 33          ; Our string is 33 characters long
	mov si, hello
	call print_bytes_si

	jmp $               ; Infinite loop

hello db 'Welcome to loadnothing stage 1!', 13, 10                   ; \r\n

times (446 - ($ - $$)) db 0x00
