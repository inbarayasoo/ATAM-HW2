.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rax
	pushq %rbx
	pushq %rcx
	pushq %rdx
	pushq %rsi
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	xor %rcx,%rcx
	xor %rdx,%rdx
	xor %rdi,%rdi
	xor %rax,%rax
	movq 8(%rbp),%rdx
	movq (%rdx), %rcx
	cmpb $0x0f,%cl
	je two_byte

	one_byte:
	movb %cl, %al
	movq %rax, %rdi
  	call what_to_do
  	cmpq $0, %rax
  	jne rerutn_isnt_zero
  	je rerutn_is_zero

	two_byte:
	movb %ch, %al
	movq %rax, %rdi
  	call what_to_do
  	cmpq $0, %rax
  	jne rerutn_isnt_zero
  	je rerutn_is_zero

	rerutn_is_zero:
				popq %r15
				popq %r14
				popq %r13
				popq %r12
				popq %r11
				popq %r10
				popq %r9
				popq %r8
				popq %rsi
				popq %rdx
				popq %rcx
				popq %rbx
				popq %rax
				movq %rbp, %rsp
				popq %rbp
	jmp *old_ili_handler

	rerutn_isnt_zero:
			movq %rax, %rdi
			cmpb $0x0f,%cl
			je len_two_byte
		
			addq $1 , 8(%rbp)
			jmp pop_reg2

			len_two_byte:
			addq $2 , 8(%rbp)

			pop_reg2:
				popq %r15
				popq %r14
				popq %r13
				popq %r12
				popq %r11
				popq %r10
				popq %r9
				popq %r8
				popq %rsi
				popq %rdx
				popq %rcx
				popq %rbx
				popq %rax
				addq $8, %rsp
				movq %rbp, %rsp
				popq %rbp

	iretq



