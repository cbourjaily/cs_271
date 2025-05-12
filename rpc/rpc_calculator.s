# Christopher Vote
# 934-315-400


/* === Constants === */
.equ EXIT_ERROR, 1	# Equate directive for error exit code


/* === External C library functions used === */
.extern strtoll		# Converts a string to a long long (64-bit signed integer)
.extern strcmp		# Compares two strings
.extern fprintf		# Prints formatted output to a stream (stderr/stdout)
.extern exit		# Exits the program


.section .rodata
parse_error_fmt:
	/* Format string for parse errors */
	.asciz "%s: invalid token: `%s'\n"

reduction_error_operands_fmt:
	/* Format string for reduction errors: not enough operands*/
	.asciz "%s: reduction error: not enough operands\n"

reduction_error_operators_fmt:
	/* Format string for reduction errors: not enough operators*/
	.asciz "%s: reduction error: not enough operators\n"

	/* Operator strings for strcmp */
	op_plus:	.asciz "+"
	op_minus:	.asciz "-"
	op_multiply:	.asciz "*"
	op_divide:	.asciz "/"

	/* Result format */
	result_fmt: .asciz "%lld\n"


.section .text
.globl main
.type main, @function
main:
	pushq %rbp		# Saves the base pointer
	movq %rsp, %rbp		# Sets base pointer for the current stack

	/* Captures argc and argv in callee-saved registers */
	movq %rdi, %r14			# Save argc in %r14
	movq %rsi, %rbx			# Save argv in %rbx
        movq (%rbx), %r13        	# save argv[0] in %r13


	/* Save callee-saved registers */
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15


	leaq -8(%rsp), %rsp	# Ensures that %rsp is 16-byte aligned

	movq %rsp, %r12		#  Initializes base pointer for operands stack

check_for_args:
	cmpq $1, %r14			# if true, only argc is in the register
	jle exit_with_success		# jump to exit if above is true

	movq $1, %r15			# Sets %r15 to start at argv[1]

parse_loop:	/* Iterates through the strings and extracts values */
	cmpq %r15, %r14		# Checks if there are arguments left to parse
	je validate_stack	# Exits loop if argc has been reached

	/* Load argv[%r15] into %rdi for strtoll */
	movq %r15, %rax
	movq (%rbx, %rax, 8), %rdi		# Sets %rdi to equal argv[%r15]

	/* Prepares endptr for strtoll */
	subq $8, %rsp		# Allocate 8 bytes
	movq %rsp, %rsi		# Sets rsi as the end pointer

	/* Align stack and call strtoll to convert the string to long long */
	movq %rsp, %r10
	andq $-16, %rsp
	call strtoll
	movq %r10, %rsp		# Restore the stack

	/* Check whether the entire string was converted. If so, the endpter is 0 */
	movq (%rsi), %rcx	# %rcx is the endptr
	cmpb $0, (%rcx)		# Checks the endptr against 0
	je push_integer		# If yes, it is a valid integer

	/* Moves the token to %rsi */
	movq %rdi, %rsi		# %rsi now holds the token being compared

       /* Check whether the token is the plus operator (if it is not an integer) */
	lea op_plus(%rip), %rdi		# Loads the plus operator into %rdi
	call strcmp		# Calls the C function to compare the token and the plus operator
	test %rax, %rax		# Tests if %rax is equal
	je do_addition		# If equal, the token matches the plus operator; jump to do_addition

	/* Check whether the token is a minus operator (if it is not a plus operator) */
        lea op_minus(%rip), %rdi         # Loads the minus operator into %rdi
        call strcmp             # Calls the C function to compare the token and the minus operator
        test %rax, %rax         # Tests if %rax is equal
        je do_subtraction       # If equal, the token matches the plus operator; jump to do_addition

        /* Check whether the token is a multiply operator (if it is not a plus operator) */
        lea op_multiply(%rip), %rdi         # Loads the multiply operator into %rdi
        call strcmp             # Calls the C function to compare the token and the multiply operator
        test %rax, %rax         # Tests if %rax is equal
        je do_multiplication    # If equal, the token matches the plus operator; jump to do_addition

        /* Check whether the token is a divide operator (if it is not a plus operator) */
        lea op_divide(%rip), %rdi         # Loads the divide operator into %rdi
        call strcmp             # Calls the C function to compare the token and the divide operator
        test %rax, %rax         # Tests if %rax is equal
        je do_division          # If equal, the token matches the plus operator; jump to do_addition

	inc %r15		# Increments the index register
	jmp parse_error		# Jumps to parse error if token is neither an integer nor known operator


do_addition:




do_subtraction:



do_multiplication:



do_division:



parse_error:
	movq stderr(%rip), %rdi
	leaq parse_error_fmt(%rip), %rsi
	movq %r13, %rdx


	movq %rdx, %rcx
	movq %rsi, %rdx

	xor %rax, %rax
	call fprintf

	jmp exit_with_error


reduction_error_operands:



reduction_error_operators:



validate_stack:
	/* Checks that there is exactly one value left on the operand stack */
	movq %rsp, %rax
	cmpq %r12, %rax		# Compares stack pointer to stack base
	je print_result		# If equal, the stack is valid
	jmp reduction_error_operators	# Otherwise, there are excessive values remaining



print_result:



exit_with_error:
	/* restores callee-saved registers in case where an error occured */
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	movq %rbp, %rsp
	popq %rbp

	movq $EXIT_ERROR, %rdi		# Exit code 1 for error

	/* aligning the stack */
	movq %rsp, %r15
	andq $-16, %rsp
	call exit	 	# Calls the C library standard exit command


exit_with_success:
	/* restores callee-saved registers in case operations completed successfully */
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	movq %rbp, %rsp
	popq %rbp

	xorq %rdi, %rdi		# Exit code 0 for success

	/* aligning the stack */
	movq %rsp, %r15
	andq $-16, %rsp
	call exit	 	# Calls the C library standard exit command



# ============ Notes =====================
# Notes on argc and argv
#
# When main is called, the System V ABI passes:
#   %rdi = argc (number of command-line arguments, including the program name)
#   %rsi = argv (pointer to an array of strings; each string is one argument)
#
# argv[0] is the program name (e.g., "./rpc")
# argv[1] to argv[argc - 1] are the actual input tokens (numbers or operators)
#
# In this program:
#   - argc is saved into %r14
#   - argv is saved into %rbx
#   - argv[0] (program name) is saved into %r13 for use in error messages
# ========================================
