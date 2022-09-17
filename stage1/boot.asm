[org 0x7c00]

%define STAGE2START 0x7e00
%define STAGE2SECTORS (STAGE2SIZE + 511) / 512

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
print_u8:
	mov ah, 0x0e ; TTY output
	mov bh, 0x00 ; Page 0
	mov bl, 0x07 ; Color: Light grey on black background
	int 0x10

	ret

; Call print_al on all characters in si
; si must be null terminated
print_str:
	mov cl, 0 ; Start with iteration 0 - equivalent of int i = 0
.print_str_loop:
	lodsb              ; Load next characet of si into al

	cmp al, 0          ; Null terminator?
	je .print_str_exit ; If yes, we are done

	call print_u8
	inc cl

	jmp .print_str_loop

.print_str_exit:
	ret

stage2_error:
	mov si, error
	call print_str

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
	mov bh, 0             ; Page
	mov dh, 0             ; Row
	mov dl, 0             ; Column
	int 0x10

	mov si, hello
	call print_str

	mov ah, 0x02          ; Read sectors
	mov al, STAGE2SECTORS ; Stage 2 size in sectors
	xor ch, ch            ; Cylinder 0
	mov cl, 2             ; Second sector, they start at 1
	xor dh, dh            ; Head 0
	mov dl, 0x80          ; Hard Drive 1
	mov bx, STAGE2START   ; Memory address to load stage 2 into
	int 0x13

	jc stage2_error       ; Carry flag is set if there was an error

	cmp al, STAGE2SECTORS ; Have we read as many sectors as we requested?
	jne stage2_error

	jmp STAGE2START       ; Hand over control to stage 2

hello db 'Welcome to loadnothing stage 1!', 13, 10, 0 ; \r\n\0
error db 'Error reading stage 2 from disk', 13, 10, 0 ; \r\n\0

times (446 - ($ - $$)) db 0x00
