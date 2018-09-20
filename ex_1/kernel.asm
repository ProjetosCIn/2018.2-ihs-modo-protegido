[bits 16]
org 0x7e00
jmp _start


oi: db 'oi, beleza', 0

printString:
	;empilha os registradores q serão utilizados
	push ax;
	push ds
	push cx

	mov ax, 0
	mov ds,ax

	mov cl,0
	.loop:
		lodsb
		cmp cl,al;como para pra ver se se zero
		je .exit;se for zero fim da string
		;printa caracter q está em al
		mov ah, 0xE
		mov bh,0
		int 0x10
		jmp .loop
	.exit:
	;desempilha os registradores q foram utilizados
	pop cx
	pop ds
	pop ax
	ret

; _start:
; mov si,oi
; call printString

gdt_start:
gdt_null:
    dd 0 ; null descriptor
    dd 0

gdt_code: ; code descriptor
    dw 0FFFFh ; limit low
    dw 0 ; base low
    db 0 ; base middle
    db 10011010b ; access
    db 11001111b ; granularity
    db 0 ; base high

gdt_data: ; data descriptor
    dw 0FFFFh ; limit low
    dw 0 ; base low
    db 0 ; base middle
    db 10010010b ; access
    db 11001111b ; granularity
    db 0 ; base high

end_of_gdt:
toc:

    dw end_of_gdt - gdt_start - 1 ; limit (Size of GDT)
    dd gdt_start ; base of GDT

_start:
    call InstallGDT
    cli
    mov eax, cr0 ; setar bit 0 (PE) para 1
    or eax, 1
    mov cr0, eax
    jmp 08h:Stage3

InstallGDT:

    cli ; clear interrupts
    pusha ; save registers
    lgdt [toc] ; load GDT into GDTR
    sti ; enable interrupts
    popa ; restore registers
    ret

[bits 32]

; msg        db           'Hello World' , 0x0a ;mensagem + LF, para pular a linha
; len        equ          $ - msg   ; tamanho da mensagem

Stage3:
    
    mov ax, 10h
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 90000h

    call ClrScr32

    mov byte [ds:0x0B8000], 'H'
    mov byte [ds:0x0B8001], 0x0F
    mov byte [ds:0x0B8002], 'E'
    mov byte [ds:0x0B8003], 0x0F
    mov byte [ds:0x0B8004], 'L'
    mov byte [ds:0x0B8005], 0x0F
    mov byte [ds:0x0B8006], 'L'
    mov byte [ds:0x0B8007], 0x0F
    mov byte [ds:0x0B8008], 'O'
    mov byte [ds:0x0B8009], 0x0F


    mov eax, cr0 ; setar bit 0 (PE) para 1
    and eax, fffffffeh  ;31 bits 1 e o último 0
    mov cr0, eax


 STOP:

 	cli
	hlt


ClrScr32:
    PUSHAD
    CLD
    MOV EDI, 0xB8000
    MOV CX, 80 * 25
    MOV AH, 0x0F   ; atributo
    MOV AL, ' '   
    ; caractere nulo
    REP STOSW
    POPAD
    RET