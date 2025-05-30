# Author: Christopher Vote (934-315-400)


 
# * Reverse Polish Notation (RPN) Calculator
#  
# * Filename: rpn.s
# * Description:
# *   An x86-64 assembly program that parses and evaluates Reverse Polish expressions.
# *   It uses command-line arguments as input tokens and simulates a computation stack using %rsp.
# *   Supports +, -, *, / with proper error handling (parse errors, reduction errors, division by zero).
# 
# * Highlights:
# *   - Follows System V AMD64 ABI
# *   - Uses C library functions: strtoll, strcmp, fprintf, exit
# *   - Fully PIC-compliant (RIP-relative addressing)
# *   - Stack is aligned before all function calls


# Citation:
# Among additional sources consulted during the development of this program,
# I made extensive use of the following reference:
#  
# Jonathan Bartlett. *Learn to Program with Assembly: Foundational Learning for New Programmers*.  
# Bartlett Publishing, 2021. ISBN: 978-1948917043.



/* === Register Notes === */


/* --- System V ABI Register Classification --- */
/* Caller-saved:  %rax, %rcx, %rdx, %rsi, %rdi, %r8–%r11 */
/* Callee-saved:  %rbx, %rbp, %r12–%r15 */
/* Argument order: %rdi, %rsi, %rdx, %rcx, %r8, %r9 */
/* Return value: %rax */
/* Stack pointer: %rsp (must be 16-byte aligned before C function calls) */


/* --- Register Usage in This Program --- */
# %r12 — Holds the current argv[i] token throughout the parsing loop
# %r13 — Used to preserve %rsp when aligning stack for function calls (callee-saved)
# %r14 — Initial %rsp (stack base); used to compute operand stack depth for validation
# %r15 — Unused (available for future expansion or debugging)
# %rbp — Used as frame pointer (standard prologue/epilogue usage)
# %rsp — Actively manipulated for operand storage (simulates evaluation stack)
# %rcx — Used for printing the offending token in parse errors


/* --- Arithmetic Register Usage --- */
# %rax — First operand for arithmetic operations; also holds the result
# %r11 — Second operand for arithmetic (add, sub, mul, div)
# %rdx — Used during signed division; extended from %rax using `cqto` to form 128-bit dividend


/* === Constants === */
.equ EXIT_ERROR, 1				# Equate directive for error exit code


/* === External C library functions used === */

# Compares two strings
# Returns 0 if s1 == s2; -val if s1 < s2; +val if s1 > s2 
.extern strcmp		

# Converts string to 64-bit integer
.extern strtoll		

# Pointer to standard error output stream (FILE*)
.extern stderr					# Standard error

# Prints a formatted string to a stream (e.g., stderr/stdout)
.extern fprintf		 

# Exits the program with a given exit code
.extern exit		

/* === Program entry point (linked with C library) === */ 

.section .text
.globl main
.type main, @function
main:
	pushq %rbp	
	movq %rsp, %rbp
	pushq %r12				# Save callee-saved registers
	pushq %r13
	pushq %r14				# Save the current stack pointer

	# Save initial stack pointer for validation
	movq %rsp, %r14		

	/*argc is in %rdi, argv is in %rsi*/

	cmpq $1, %rdi				# Checks if there is more than 1 argument in %rdi.
	jle exit_with_success			# If only one arg, it's just the file name. Exit program.
		
	movq (%rsi), %rax			# Load argv[0] (program name) to %rax
	movq %rax, progname(%rip)		# Save to global variable
	xor %rax, %rax			



parsing_loop:
	leaq 8(%rsi), %rsi			# Increments the current arg, as in argv[0]->argv[1]
	movq (%rsi), %r12			# Loads the next argv address into %r12
	cmpq $0, %r12				# Check for null byte
	je validate_stack


add_compare:
	pushq %r12				# Save the value of argv (current token) on the stack
	pushq %rsi				# Save argv pointer
	movq %rsp, %r13				# Move %rsp into a free callee-saved register 

	andq $-16, %rsp				# Realign %rsp; -16 = 0xfffffffffffffff0 

	leaq op_add(%rip), %rdi			# Loading the 1st argument (op_add) for strcmp 
	movq %r12, %rsi				# load the 2nd argument (current token) into %rsi 
	call strcmp				# The result is in %rax

	movq %r13, %rsp				# Restore stack pointer 
	popq %rsi				# Restore the argv pointer 
	popq %r12				# Restore argv value
	cmpq $0, %rax
	je operation_add


sub_compare:
	pushq %r12				# Save the value of argv (current token) on the stack
	pushq %rsi				# Save argv pointer
	movq %rsp, %r13				# Move %rsp into a free callee-saved register 

	andq $-16, %rsp				# Realign %rsp; -16 = 0xfffffffffffffff0 

	leaq op_sub(%rip), %rdi			# Loading the 1st argument (op_sub) for strcmp 
	movq %r12, %rsi				# load the 2nd argument (current token) into %rsi 
	call strcmp				# The result is in %rax

	movq %r13, %rsp				# Restore stack pointer 
	popq %rsi				# Restore the argv pointer 
	popq %r12				# Restore argv value
	cmpq $0, %rax
	je operation_subtract


multiply_compare:
	pushq %r12				# Save the value of argv (current token) on the stack
	pushq %rsi				# Save argv pointer
	movq %rsp, %r13				# Move %rsp into a free callee-saved register 

	andq $-16, %rsp				# Realign %rsp; -16 = 0xfffffffffffffff0 

	leaq op_multiply(%rip), %rdi		# Loading the 1st argument (op_sub) for strcmp 
	movq %r12, %rsi				# load the 2nd argument (current token) into %rsi 
	call strcmp				# The result is in %rax

	movq %r13, %rsp				# Restore stack pointer 
	popq %rsi				# Restore the argv pointer 
	popq %r12				# Restore argv value
	cmpq $0, %rax
	je operation_multiply


divide_compare:
	pushq %r12				# Save the value of argv (current token) on the stack
	pushq %rsi				# Save %argv pointer
	movq %rsp, %r13				# Move %rsp into a free callee-saved register 

	andq $-16, %rsp				# Realign %rsp; -16 = 0xfffffffffffffff0 

	leaq op_divide(%rip), %rdi		# Loading the 1st argument (op_sub) for strcmp 
	movq %r12, %rsi				# load the 2nd argument (current token) into %rsi 
	call strcmp				# The result is in %rax

	movq %r13, %rsp				# Restore stack pointer 
	popq %rsi				# Restore the argv pointer 
	popq %r12				# Restore argv value
	cmpq $0, %rax
	je operation_divide
	
	jmp num_convert				# Could feasibly comment out to save a jump

num_convert:
        pushq %r12               		# Save the value of argv (current token) on the stack
        pushq %rsi               		# Save argv pointer
	movq %rsp, %r13				# Move %rsp into a free callee-saved register

	andq $-16, %rsp				# Realign %rsp; -16 = 0xfffffffffffffff0 

	movq %r12, %rdi				# Move argv value into %rdi (first argument)
	leaq endptr(%rip), %rsi			# Set endptr for %rsi (second argument
	xor %rdx, %rdx				# Set %rdx to zero
	
	call strtoll				# Converted integer into %rax

	movq %r13, %rsp				# Restore stack pointer
	popq %rsi				# Restore the argv pointer
	popq %r12				# Restore the argv value

	movq endptr(%rip), %r8			# Load endptr into %r8
	movb (%r8), %r9b			# Load the byte pointed to by endptr
	cmpb $0, %r9b				# Confirm that it is the null pointer

	jne parse_error				# If endptr is not null, token wasn't fully consumed by strtoll (invalid number)

	pushq %rax				# Push the converted integer to the stack
	jmp parsing_loop		


/* The next four sections check the stack to confirm there are at least two values. If not, it is treated as a reduction error.
If so, they pop the first two values performs the relavent operation, and returns the sum to the stack. */

operation_add:
	/* Check for the presence of at least 16 bytes (2 values) on the stack */
	movq %r14, %r10				# %r14 holds the value of %rsp prior to integer arithmetic
	subq %rsp, %r10				# Obtain the difference as compared to %rsp's current state
	cmpq $16, %r10				# 16 bytes represents two integer values.
	jl reduction_err_operand		# If there are less than 16 bytes, it is an error.

	/* Perform addition operation */
	popq %r11				# Pop the second operand into %r11
	popq %rax				# Pop the first operand into %rax
	addq %r11, %rax				# Add the two values, result is in %rax
	pushq %rax				# Push the result back on the stack
	jmp parsing_loop			# Continue parsing the next token


operation_subtract:
	/* Check for the presence of at least 16 bytes (2 values) on the stack */
	movq %r14, %r10				# %r14 holds the value of %rsp prior to integer arithmetic
	subq %rsp, %r10				# Obtain the difference as compared to %rsp's current state
	cmpq $16, %r10				# 16 bytes represents two integer values.
	jl reduction_err_operand		# If there are less than 16 bytes, it is an error.

	/* Perform subtraction operation */
	popq %r11				# Second operand in %r11 (subtrahend)
	popq %rax				# First operand in %rax (minuend)
	subq %r11, %rax				# %rax = %rax - %r11
	pushq %rax				# Push the result back on the stack
	jmp parsing_loop			# Continue parsing the next token


operation_multiply:
	/* Check for the presence of at least 16 bytes (2 values) on the stack */
	movq %r14, %r10				# %r14 holds the value of %rsp prior to integer arithmetic
	subq %rsp, %r10				# Obtain the difference as compared to %rsp's current state
	cmpq $16, %r10				# 16 bytes represents two integer values.
	jl reduction_err_operand		# If there are less than 16 bytes, it is an error.

	/* Perform multiplication operation */
	popq %r11				# Pop the second operand into %r11
	popq %rax				# Pop the first operand into %rax
	imulq %r11				# Multiply: %rax = %rax * %r11 (signed multiply)
	pushq %rax				# Push the result back on the stack
	jmp parsing_loop			# Continue parsing the next token



operation_divide:
	/* Check for the presence of at least 16 bytes (2 values) on the stack */
	movq %r14, %r10				# %r14 holds the value of %rsp prior to integer arithmetic
	subq %rsp, %r10				# Obtain the difference as compared to %rsp's current state
	cmpq $16, %r10				# 16 bytes represents two integer values.
	jl reduction_err_operand		# If there are less than 16 bytes, it is an error.

	/* Perform the division operation */
	popq %r11				# Divisor (second operand) in %rax
	popq %rax				# Divident (first operand) in %rax
	cqto					# sign-extend %rax into %rdx

	cmpq $0, %r11				# Check that the divisor is not zero
	je divide_by_zero			# Error for division by zero

	idivq %r11				# Signed division: (%rdx:%rax) / %r11 -> %rax
	pushq %rax				# Push the result back on the stack
	jmp parsing_loop			# Continue parsing the next token


validate_stack:
	movq %r14, %r10				# %r14 holds the value of %rsp prior to integer arithmetic.
	subq %rsp, %r10				# There should be one integer value on the stack (8 bytes).	
	cmpq $8, %r10				# Checks for single integer value
	jne reduction_err_operator		# If not exactly 8 bytes, reduction error
	jmp print_result			# Otherwise, print the result


divide_by_zero:
	movq stderr(%rip), %rdi			# Loads the address of the stderr stream into %rdi (1st argument)
	movq $divide_by_zero_error, %rsi	# Loads the address of the format string to %rsi (2nd argument)
	movq progname(%rip), %rdx		# Loads the program name (stored in progname) in %rdx (3rd argument)
	movq %r12, %rcx				# Move the token into %rcx (4th argument)

	xor %rax, %rax				# Mandatory to zero %rax before a variadic function call.
	call fprintf				# Call C library's fprintf with the above 4 arguments
	jmp exit_with_error


reduction_err_operator:
        movq stderr(%rip), %rdi			# Loads the address of the stderr stream into %rdi (1st argument)
        movq $reduction_error_operator, %rsi	# ioads the address of the format string to %rsi (2nd argument)
        movq progname(%rip), %rdx		# Loads the program name (stored in progname) in %rdx (3rd argument)

        xor %rax, %rax				# Mandatory to zero %rax before a variadic function call.
        call fprintf				# Call C library's fprintf with the above 4 arguments
        jmp exit_with_error


reduction_err_operand:
        movq stderr(%rip), %rdi			# Loads the address of the stderr stream into %rdi (1st argument)
        movq $reduction_error_operand, %rsi	# Loads the address of the format string to %rsi (2nd argument)
        movq progname(%rip), %rdx		# Loads the program name (stored in progname) in %rdx (3rd argument)

        xor %rax, %rax				# Mandatory to zero %rax before a variadic function call.
        call fprintf				# Call C library's fprintf with the above 4 arguments
        jmp exit_with_error             
	

parse_error:
	movq stderr(%rip), %rdi			# Loads the address of the stderr stream into %rdi (1st argument)
	movq $parse_error_fmt, %rsi		# Loads the address of the format string to %rsi (2nd argument)
	movq progname(%rip), %rdx		# Loads the program name (stored in progname) in %rdx (3rd argument)
	movq %r12, %rcx				# Move the token into %rcx (4th argument).

	xor %rax, %rax				# Mandatory to zero %rax before a variadic function call.
	call fprintf				# Call C library's fprintf with the above 4 arguments.
	jmp exit_with_error			# Could feasibly be commented out to save a jump.


print_result:
	popq %rsi				# Pop final result into %rsi (1st argument to printf after format)
	movq $result_fmt, %rdi			# Format string: "%lld\n"
	xorq %rax, %rax				# %rax zeroed for variadic function call
	call printf
	jmp exit_with_success			# Could feasibly be commented out to save a jump.


exit_with_error:
	popq %r14				# Restore callee-saved registers
	popq %r13
	popq %r12
	movq %rbp, %rsp
	popq %rbp
	movq $EXIT_ERROR, %rdi			# Exit code 1 for error
	call exit				# Calls the C library standard exit command


exit_with_success:
	popq %r14				# Restore callee-saved registers
	popq %r13
	popq %r12
	movq %rbp, %rsp
	popq %rbp
        xorq %rdi, %rdi				# Exit code 0 for success
        call exit				# Calls the C library standard exit command
        
                       
 .section .bss
progname:
	.space 8

endptr:
	.quad 0					

.section .rodata
parse_error_fmt:
	/* Format string for parse errors */
	.asciz "%s: invalid token: `%s'\n"

reduction_error_operand:
	/* Format string for reduction errors: not enough operands */
	.asciz "%s: reduction error: not enough operands\n"

reduction_error_operator:
	/* Format string for reduction errors: not enough operators */
	.asciz "%s: reduction error: not enough operators\n"

divide_by_zero_error:
	/* Format string for division by zero is undefined. */
	.asciz "%s: division by zero is undefined.\n"


/* Operator strings for strcmp */
op_add:
	.asciz "+"

op_sub:
	.asciz "-"

op_multiply:
	.asciz "*"

op_divide:
	.asciz "/"


/* Result format */
	result_fmt:	.asciz "%lld\n"
