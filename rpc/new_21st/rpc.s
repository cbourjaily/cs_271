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
	# Saving argc to %r14 for now, just in case
	movq %rdi, %r14
	# Saving argv in %r15 for now, just in case.
	movq %rsi, %r15
	# Checks if there is more than 1 argument in %rdi.
	cmp $1, %rdi			

	# If only one arg, it's just the file name. Exit program.
	jle exit_with_success		

parsing_loop:
	# Increments the current arg, as in argv[0]->argv[1]
	leaq 8(%rsi), %rsi
	# Loads the next argv address into %r12
	movq(%rsi), %r12

	# Check for null byte
	cmpq $0, %r12
	je print_result
	
/* If we got this far, we still have a working string. */
add_compare:













exit_with_success:

        xorq %rdi, %rdi         # Exit code 0 for success

        /* aligning the stack */
#       movq %rsp, %r15
#       andq $-16, %rsp
#	movq %r15, %rsp
        call exit               # Calls the C library standard exit command
        
        
        
        
        





