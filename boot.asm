[bits 16]
[org 0x7C00]

call boot

; Print AL register
print_al:
	mov ah, 0x0E
	mov bh, 0x00
	mov bl, 0x07
	int 0x10

	ret

; Call print_al on all characters in SI
; SI must be null terminated
print_bytes_si:
	mov cl, 0 ; Start with iteration 0 - equivalent of int i = 0
print_bytes_si_loop:
	mov al, [si]
	call print_al

	inc si
	inc cl

	cmp cl, ch
	jb print_bytes_si_loop

	ret

; APM is not supported
apm_error:
	mov ch, 9           ; Our string is 9 characters long
	mov si, apm_err
	call print_bytes_si

	jmp $               ; Infinite loop

; Check APM support
apm_chk:
	mov ah, 0x53     ; This is an APM command
	mov al, 0x00     ; APM: Installation Check
	mov bx, 0x0000   ; Device ID (0 is APM BIOS)
	int 0x15         ; Call

	jc apm_error ; Carry flag is set if there was an error

	cmp ah, 1        ; APM major version must be at least one
	jb apm_error

	cmp al, 1        ; APM minor version must be at least one
	jb apm_error

	ret


; Disconnect from any APM interface
apm_disco:
	mov ah, 0x53           ; This is an APM command
	mov al, 0x04           ; APM: Disconnect
	mov bx, 0x0000         ; Device ID (0 is APM BIOS)
	int 0x15               ; Call

	jc .apm_disco_error    ; Carry flag is set if there was an error
	jmp .apm_disco_success

; Disconnecting any APM interface failed
.apm_disco_error:
	cmp ah, 0x03  ; Error code for no interface connected
	jne apm_error

; No interface are connected now
.apm_disco_success:
	ret

; Connect to an APM interface
apm_connect:
	mov ah, 0x53   ; This is an APM command
	mov bx, 0x0000 ; Device ID (0 is APM BIOS)
	int 0x15       ; Call

	jc apm_error ; Carry flag is set if there was an error
	ret

; Set the APM Driver Version to 1.1
apm_drv_init:
	mov ah, 0x53   ; This is an APM command
	mov al, 0x0E   ; APM: Set Driver Supported Version
	mov bx, 0x0000 ; Device ID (0 is APM BIOS)
	mov ch, 1      ; APM Driver Major Version Number
	mov cl, 1      ; APM Driver Minor Version Number
	int 0x15       ; Call

	jc apm_error ; Carry flag is set if there was an error
	ret

; Enable APM Power Management
apm_mgmt_on:
	mov ah, 0x53   ; This is an APM command
	mov al, 0x08   ; APM: Change power management state
	mov bx, 0x0001 ; on all devices
	mov cx, 0x0001 ; to on
	int 0x15       ; Call

	jc apm_error   ; Carry flag is set if there was an error
	ret

; Power down the system
apm_power_off:
	mov ah, 0x53   ; This is an APM command
	mov al, 0x07   ; APM: Set power state
	mov bx, 0x0001 ; on all devices
	mov cx, 0x0003 ; to off
	int 0x15       ; Call

	jc apm_error   ; Carry flag is set if there was an error
	ret

; Main
boot:
	call apm_chk        ; Is APM supported?
	call apm_disco      ; Disconnect from any APM interface

	mov al, 0x01        ; Interface to connect to: Real Mode
	call apm_connect    ; Connect to APM interface

	call apm_drv_init   ; Set the APM Driver Version to 1.1
	call apm_mgmt_on    ; Enable Power Management

	; Clear the screen
	mov ah, 0x06
	mov al, 0x00
	mov bh, 0x07
	mov ch, 0x00
	mov cl, 0x00
	mov dh, 0xFF
	mov dl, 0xFF
	int 0x10

	; Move cursor to 0, 0 on page 0
	mov ah, 0x02
	mov bh, 0           ; Page
	mov dh, 0           ; Row
	mov dl, 0           ; Column
	int 0x10

	mov ch, 5           ; Our string is 5 characters long
	mov si, hello
	call print_bytes_si

	mov ch, 29          ; Our string is 29 characters long
	mov si, paktc       ; paktc: Press any key to continue
	call print_bytes_si

	mov ah, 0x00        ; Keyboard: Read key press
	int 0x16            ; Call

	call apm_power_off
	jmp $               ; Infinite loop

hello db 'foo', 13, 10                   ; \r\n
apm_err db 'APM Error'
paktc db 'Press any key to continue... '
