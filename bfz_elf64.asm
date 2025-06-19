BITS 64

	org 0x400000

; ================ CONSTANTS ================

TAPE_SIZE equ 30000 

; ================ ELF HEADER ================

ehdr:
	db 0x7F, "ELF"
	db 2
	db 1
	db 1
	db 0
	times 8 db 0
	dw 2
	dw 0x3E
	dd 1
	dq _start
	dq phdr - $$
	dq 0
	dd 0
	dw ehdrsize
	dw phdrsize
	dw 1
	dw 0
	dw 0
	dw 0

ehdrsize equ $ - ehdr

phdr:
	dd 1
	dd 5
	dq 0
	dq $$
	dq $$
	dq filesize
	dq filesize
	dq 0x1000

phdrsize equ $ - phdr

; ================ EXECUTABLE CODE ================



_start:

	; get the end of the data segment...
	mov rax, 12
	xor rdi, rdi
	syscall

	; ...push onto stack for later use...
	push rax

	; ...and extend it by TAPE_SIZE bytes.
	lea rdi, [rax+TAPE_SIZE]
	mov rax, 12
	syscall

	; set the data pointer to the previous data segment
	pop r13

	; load the initial instruction pointer
	mov r12, src

_loop:

	mov bl, byte [r12]

	push _loop.next

	cmp bl, '>'
	je _loop.inc
	
	cmp bl, '<'
	je _loop.dec
	
	cmp bl, '+'
	je _loop.incb
	
	cmp bl, '-'
	je _loop.decb
	
	cmp bl, '.'
	je _func.write

	cmp bl, ','
	je _func.read

	cmp bl, '['
	je _func.jmp

	cmp bl, ']'
	je _func.ret

	ret

_loop.inc:

	inc r13
	ret

_loop.dec:

	dec r13
	ret

_loop.incb:

	inc byte [r13]
	ret

_loop.decb:

	dec byte [r13]
	ret

_loop.next:
	
	inc r12

	; exit if we reach the end of the tape
	cmp byte [r12], 0
	jne _loop

_loop.end:	

	; set error code 0
	xor rdi, rdi
	
_exit:

	mov rax, 60
	syscall



_func.write:

	; perserve data and instruction pointers
	push r13
	push r12
	
	; write 1 character to stdout
	mov rax, 1
	mov rdi, 1
	lea rsi, [r13]
	mov rdx, 1
	syscall

	; restore data and instruction pointers
	pop r12
	pop r13
	
	ret

_func.read:

	; perserve data and instruction pointers
	push r13
	push r12
	
	; read 1 character from stdin
	mov rax, 0
	xor rdi, rdi
	lea rsi, [r13]
	mov rdx, 1
	syscall

	; restore data and instruction pointers
	pop r12
	pop r13
	
	ret



_func.jmp:

	cmp byte [r13], 0
	jne _func.jmp.end

	mov rax, 1

_func.jmp.loop:

	inc r12

	mov bl, byte [r12]

	cmp bl, '['
	je _func.jmp.loop.inc

	cmp bl, ']'
	je _func.jmp.loop.dec

_func.jmp.loop.check:

	cmp rax, 0
	je _func.jmp.end

	jmp _func.jmp.loop

_func.jmp.loop.inc:

	inc rax
	jmp _func.jmp.loop.check

_func.jmp.loop.dec:

	dec rax
	jmp _func.jmp.loop.check

_func.jmp.end:

	ret
		


_func.ret:

	cmp byte [r13], 0
	je _func.ret.end

	mov rax, 1

_func.ret.loop:

	dec r12

	mov bl, byte [r12]

	cmp bl, ']'
	je _func.ret.loop.inc

	cmp bl, '['
	je _func.ret.loop.dec

_func.ret.loop.check:

	cmp rax, 0
	je _func.jmp.end

	jmp _func.ret.loop

_func.ret.loop.inc:

	inc rax
	jmp _func.ret.loop.check

_func.ret.loop.dec:

	dec rax
	jmp _func.ret.loop.check

_func.ret.end:

	ret


	
src: db "++++++++[>++++[>++>+++>+++>+<<<<-]>+>->+>>+[<]<-]>>.>>---.+++++++..+++.>.<<-.>.+++.------.--------.>+.>++.", 0


filesize equ $ - $$
