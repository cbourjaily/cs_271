# Christopher Vote
# 934-315-400


.section .data
progname:
	.space 8

parse_error_fmt:
	/* Format string for parse errors */
	.asciz "%s: invalid token: `%s'\n"

reduction_error_operands_fmt:
	/* Format string for reduction errors: not enough operands*/
	.asciz "%s: reduction error: not enough operands\n"

reduction_error_operators_fmt:
	/* Format string for reduction errors: not enough operators*/
	.asciz "%s: reduction error: not enough operators\n"

operator_strings_for_strcmp:
	op_plus:	.asciz "+"
	op_minus:	.asciz "-"
	op_multiply:	.asciz "*"
	op_divide:	.asciz "/"

        
Result_format:
	result_fmt:	.asciz "%lld\n"



/* === Register Calling Convention Notes === */

/* According to the System V ABI, the stack is supposed to be aligned to a multiple of */
/* 16 bytes immediately before every function call. “Aligned to 16 bytes” means that */
/* the address of the stack pointer (%rsp) should be a multiple of 16. */


/* === Constants === */
.equ EXIT_ERROR, 1	# Equate directive for error exit code

/* === External C library functions used === */

# Compares two strings
# Returns 0 if s1 == s2; -val if s1 < s2; +val if s1 > s2 
.extern strcmp		

# mConverts string to 64-bit integer
.extern strtoll		

# Pointer to standard error output stream (FILE*)
.extern stderr		# Standard error

# Prints a formatted string to a stream (e.g., stderr/stdout)
.extern fprintf		 

# Exits the program with a given exit code
.extern exit		

/* === Program entry point (linked with C library) === */ 

.section .text
.globl main
.type main, @function

/* Caller-saved: %rax, %rcx, %rdx, %rsi, %rdi, %r8–%r11 */
/* Callee-saved: %rbx, %rbp, %r12–%r15 */
/* Integer/pointer argument registers: %rdi, %rsi, %rdx, %rcx, %r8, %r9 */
/* argc is in %rdi. argv is in %rsi. */

main:
	# Checks if there is more than 1 argument in %rdi.
	cmp $1, %rdi			

	# If only one arg, it's just the file name. Exit program.
	jle exit_with_success		

parsing_loop:
	# Increments the current arg, as in argv[0]->argv[1]
	leaq 8(%rsi), %rsi
	# Loads the next argv address into %r12
	movq (%rsi), %r12

	# Check for null byte
	cmpq $0, %r12
#	je print_result                                 # NERFED FOR NOW

/* If we have got this far, we still have a working string. */

add_compare:
/* Use strcmp to check if the current token is op_plus. If not, move along. If so, jump to perform operation. */
/* If we identify +, we will jump to an operation_add: Otherwise, the token will proceed. */
/* Save callee-saved registers and align the stack before the function call */ 

push %r12		# Save the value of argv (current token) on the stack
push %rsi		# Save argv pointer
movq %rsp, %r13		# Move rsp into a free callee-saved register 

andq $-16, %rsp		# Realign rsp; -16 = 0xfffffffffffffff0 

leaq op_plus(%rip), %rdi	# Loading the 1st argument (op_plus) for strcmp 
mov %r12, %rsi			# load the 2nd argument (current token) into %rsi 
call strcmp			# The result is in %rax

movq %r13, %rsp		# Restore stack pointer 
pop %rsi		# Restore the argv pointer 
pop %r12		# Restore argv value
cmp $0, %rax
je operation_add

sub_compare:







operation_add:                 /* A test of the emergency operation_add system */
	movq $7, %rdi        # exit code 1 = "matched +"
	call exit



operation_subtract:




operation_multiply:



operation_divide:



exit_with_success:

        xorq %rdi, %rdi         # Exit code 0 for success

        /* aligning the stack */
#       movq %rsp, %r15
#       andq $-16, %rsp
#	movq %r15, %rsp
        call exit               # Calls the C library standard exit command
        
        
        
        
        



