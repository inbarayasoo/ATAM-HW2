.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
	xorq %r8, %r8
	xorq %r9, %r9
	xorq %r10, %r10
 	movq %rdi, %r11 #input
	movq %rsi, %rax #key
	
	XOR_Per_Byte:
        movb (%r11 ,%r8, 1), %r9b
        movb (%rax ,%r8, 1), %r10b
        xor %r10, %r9
        movb %r9b, (%r11 ,%r8, 1)
        inc %r8
        cmp $16, %r8
        jne XOR_Per_Byte

    	ret


byteSubstitution:
	pushq %rbx
	xorq %r9, %r9
	xorq %rbx, %rbx #rbx = rcx of yan 
 	xorq %rax, %rax
    	xorq %r8, %r8
	lea sbox(%rip), %r8
    
	replace_byte_by_byte:
	 	cmpq $16, %r9
	 	je end
	 	movb (%rdi, %r9), %bl 
	 	movb (%r8, %rbx),%al
	 	movb %al, (%rdi, %r9)
	 	inc %r9
	 	jmp replace_byte_by_byte
	end:
		popq %rbx
		ret


shiftRows:
	movq $0, %r10
	movq $0, %rcx
	movq $0, %r11
	shiftLine:
		cmpq $4, %r10
		je endShifting
		movl (%rdi, %r10, 4), %r11d
		rorl %cl, %r11d
		movl %r11d, (%rdi, %r10, 4)
		inc %r10
		addb $8, %cl
		jmp shiftLine

	endShifting:
	ret


cipher:

    pushq %rbp
    movq %rsp, %rbp

    pushq %rax
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

    subq $48, %rsp
    
    movq %rdi, -8(%rbp)    
    movq %rsi, -16(%rbp)  
    movq %rdx, -24(%rbp)    
    movq $9, -32(%rbp)     
    movq $0, -40(%rbp)     
    movq $0, -48(%rbp)      

    per_block:
    call keyMixing
    inner_loop:
        call byteSubstitution
        call shiftRows

        pushq %rax
        pushq %rdi
        pushq %rsi
        pushq %rdx
        pushq %rcx
        pushq %r8
        pushq %r9
        pushq %r10
        pushq %r11
        call mixColumns
        popq %r11
        popq %r10
        popq %r9
        popq %r8
        popq %rcx
        popq %rdx
        popq %rsi
        popq %rdi
        popq %rax

        movq -8(%rbp), %rdi
        movq -16(%rbp), %rsi
        movq -24(%rbp), %rdx
        call keyMixing
        movq -32(%rbp), %r11
        movq -40(%rbp), %r8
        inc %r8
        movq %r8, -40(%rbp)
        cmp %r8, %r11
        jne inner_loop

    movq $0, %r8
    movq %r8, -40(%rbp)
    call byteSubstitution
    call shiftRows
    call keyMixing

    movq -48(%rbp), %r9    #; the counter
    movq -24(%rbp), %r10    #; len
    inc %r9
    here:
    movq -8(%rbp), %rdi
    addq $16, %rdi       #; now the next block all over again
    movq %rdi, -8(%rbp)
    movq %r9, -48(%rbp)
    cmp %r10, %r9
    jne per_block


    ;#Epilog
    movq -8(%rbp), %rdi
    movq -16(%rbp), %rsi

    movq -24(%rbp), %rdx

    popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	popq %rax
    movq %rbp, %rsp
    popq %rbp

	ret
