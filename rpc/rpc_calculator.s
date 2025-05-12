# Christopher Vote
# 934-315-400


.equ EXIT_ERROR, 1	/* Equate directive for error exit code */


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
	pushq %rbp	/* Save the base pointer */
	movq %rsp, %rbp	/* Set base pointer for the current stack */

	/* capture argc and argv in callee-saved registers */
	movq %rdi, %r14			# Save argc in %r14
	movq %rsi, %rbx			# Save argv in %rbx
        movq (%rbx), %r13        	# save argv[0] in %r13 */


	/* Save callee-saved registers */
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15


	leaq -8(%rsp), %rsp	# ensure that %rsp is 16-byte aligned */

	movq %rsp, %r12		#  initialize stack base pointer for operands

check_for_args:
	cmpq $1, %r14			/* if true, only argc is in the register */
	jle exit_with_success		/* jump to exit if above is true */


parse_loop:


parse_integer:


parse_operator:


do_addition:



do_subtraction:



do_multiplication:



do_division:



parse_error:



reduction_error_operands:



reduction_error_operators:



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

movq $EXIT_ERROR, %rdi	/* exit code 1 for error */

/* aligning the stack */
movq %rsp, %r15
andq $-16, %rsp
call exit	/* calling the C library standard exit */


exit_with_success:
/* restores callee-saved registers in case operations completed successfully */
popq %r15
popq %r14
popq %r13
popq %r12
popq %rbx
movq %rbp, %rsp
popq %rbp

xorq %rdi, %rdi		/* exit code 0 for success */

/* aligning the stack */
movq %rsp, %r15
andq $-16, %rsp
call exit	/* calling the C library standard exit */

