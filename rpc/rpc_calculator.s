# Christopher Vote
# 934-315-400


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
	push %rbp	/* Save the base pointer */
	mov %rsp, %rbp	/* Set base pointer for the current stack */

/* Save callee-saved registers */
	push %rbx
	push %r12
	push %r13
	push %r14
	push %r15

	lea -8(%rsp), %rsp	/* Ensure that %rsp is aligned to 16-byte aligned */

check_for_args:
	cmp $1, %rdi		/* if true, only argc is in the register */
	je exit			/* jump to exit if above is true */


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



exit:
