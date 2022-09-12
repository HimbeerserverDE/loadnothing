[org 0x7c00]

%define STAGE2START 0x7e00
%define STAGE2SIZE 0x7f

; Initialize registers
xor ax, ax
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

; Initialize the stack
; It grows down, overwriting this code
; I have no idea what this does exactly
mov bp, STAGE2START
mov sp, bp

jmp boot

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

stage2_error:
	mov ch, 33          ; Our string is 33 characters long
	mov si, error
	call print_bytes_si

	jmp $               ; Infinite loop

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

	mov ah, 0x02        ; Read sectors
	mov al, STAGE2SIZE  ; Stage 2 size (16 MiB) in sectors
	xor ch, ch          ; Cylinder 0
	mov cl, 2           ; Second sector, they start at 1
	xor dh, dh          ; Head 0
	mov dl, 0x80        ; Hard Drive 1
	mov bx, STAGE2START ; Memory address to load stage 2 into
	int 0x13

	jc stage2_error     ; Carry flag is set if there was an error

	cmp al, STAGE2SIZE  ; Have we read as many sectors as we requested?
	jne stage2_error

	jmp STAGE2START     ; Hand over control to stage 2

hello db 'Welcome to loadnothing stage 1!', 13, 10 ; \r\n
error db 'Error reading stage 2 from disk', 13, 10 ; \r\n

times (446 - ($ - $$)) db 0x00
