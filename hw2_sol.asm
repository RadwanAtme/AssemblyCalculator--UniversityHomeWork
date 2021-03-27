.section .text
.global	calc_expr

# Function Calc_Expr
# Parameters: RDI = string_convert, RSI = result_as_string
# Return : rax -> length of the number to print
calc_expr:
	pushq %rbp
	movq %rsp, %rbp
	movq $0, %r8
	movq %rdi, %r14 # R14 -> string_convert
	movq %rsi, %r15 # R15 -> result_as_string
	call Function
return:
	# return value: R8 = final resault

	movq %r8,%rdi
	# parameters: RDI -> the result of the calculations
	call *%r15
	# return value :RAX = len of what_to_print

	
	movq %rax, %rdx
	# parameters: RDX -> number of letters to print
	call print
	# return value: RAX -> number of letters that were printed

	movq %rbp, %rsp 
	popq %rbp 
	ret

# Function -Recursive- Function
# Parameters : r8 = the calculation so far
# Return : R8 = final result

# Paramaters throuought the proccess : R8 = calculation so far, R9 = input in reg
Function:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rax
	pushq %r8
        call Scan
	popq %r8
	popq %rax

open_bracket:
	cmp $0x28, %r9
	jne end_of_file
 	# if(open_bracket)
        call Function

end_of_file:
	cmp $0x27,%r9
        jle exit
       
number:
        cmp $0x30, %r9
        jl operation
        # if(number)
        call read_and_convert

	# RAX -> full number that was read as num
	# R9 -> next letter

	movq %rax,%r8
        jmp open_bracket
        
operation:
        cmp $0x29, %r9
        je closed_bracket
        # if(operation) 
        movq %r9,%r13
	pushq %rax 
	pushq %r8
        call Scan
	popq %r8
	popq %rax 
        
operation_minus_to_minus:
	cmp $0x2D, %r13
	jne operation_to_minus
	cmp $0x2D, %r9
	jne operation_to_minus
	# if(--)
	movq $0x2B, %r9
	jmp operation

operation_to_minus:
	cmp $0x2D, %r9
	jne operation_to_open_bracket
	# if(*-)
	pushq %rax
	pushq %r8
        call Scan
	popq %r8
	popq %rax
	movq $1,%r10
	jmp operation_to_number
	

operation_to_open_bracket:       
        cmp $0x28, %r9
	jne operation_to_number
        # if(open_bracket) 

	pushq %r8
        pushq %r13
	movq $0,%r8
        call Function
        popq %r13
        popq %r12

        call calculator
        # R8 = R12 op(R13) R8
        jmp open_bracket
         
operation_to_number:
	pushq %r10
        call read_and_convert
	popq %r10
        # RAX = full number,R9 = next letter

	cmp $1,%r10
	jne is_positive
	imul $-1,%rax,%rax
is_positive:
	movq $0,%r10
	movq %r8, %r12
	movq %rax,%r8
        call calculator
        # R8 = R12 op RAX
	jmp open_bracket
	

        
closed_bracket:
	pushq %rax
        call Scan
	popq %rax

	movq %rbp, %rsp 
	popq %rbp 
        ret

# Functions

Scan:
	pushq %rbp
	movq %rsp, %rbp

	movq $0, %rax
	movq $0, %rdi
	movq $msg, %rsi
	movq $1, %rdx
        syscall 

        movq $0, %r9
        movb (msg), %r9b

	movq %rbp, %rsp 
	popq %rbp 
        ret
      

read_and_convert:
	pushq %rbp
	movq %rsp, %rbp

        movq $0,%rax
read_loop:
	pushq %rax
	call store_and_convert
	popq %rax

        imul $10,%rax
        addq %r9,%rax  

	pushq %rax
        call Scan
	popq %rax

        cmp $0x30,%r9 
        jge read_loop

	# RAX -> full number as a string
	movq %rbp, %rsp 
	popq %rbp 
	ret

store_and_convert:
	pushq %rbp
	movq %rsp, %rbp

	movb %r9b, string
	# number is stored in $string
	movq $string,%rdi
	pushq %r8
	pushq %r9
	call *%r14
	popq %r9
	popq %r8
	# RAX -> full number as a number
	movq %rax,%r9
finish:
	movq %rbp, %rsp 
	popq %rbp 
	ret 

# Calculator Function
calculator:
	pushq %rbp
	movq %rsp, %rbp

        # R12 -> first number
        # R13 -> operation
        # R8 -> second number 

        
        cmp $0x2A, %r13
        je operation_mul
        
        cmp $0x2B, %r13
        je operation_plus
        
        cmp $0x2D, %r13
        je operation_minus
        
        jmp operation_divide
        
operation_plus:
        addq %r12,%r8
        jmp exit_operation

operation_minus:
        subq %r8,%r12
        movq %r12,%r8
        jmp exit_operation

operation_mul:
        imul %r12,%r8
        jmp exit_operation

operation_divide:
        movq %r12,%rax
	movq $0,%rdx
	cmp $0,%rax
	jge divide_is_positive
        movq $-1,%rdx
divide_is_positive:
        idiv %r8
	movq %rax,%r8
        jmp exit_operation

exit_operation:
	movq %rbp, %rsp 
	popq %rbp 
	ret

# Print Function
print:
	pushq %rbp
	movq %rsp, %rbp

	movq $1, %rax
	movq $1, %rdi
	movq $what_to_print, %rsi
        syscall 
		
	movq %rbp, %rsp 
	popq %rbp 
	ret

exit:
	movq %rbp, %rsp 
	popq %rbp 
        ret

error:

.section .data
msg: .byte 0
string: .byte 0
	.byte 0


