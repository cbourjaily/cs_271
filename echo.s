.equ SYS_write, 1
.equ SYS_exit, 60
.equ STDOUT_FILENO, 1

.global _start
.type _start, @function
_start:
  movq (%rsp), %r12	/* r12 = argc */
  cmp $1, %r12		/* Compare argc to 1 */
  jle done		/* if argc <= 1, exit */

  movq $1, %r13		/* r13 = 1, arg index */

main_loop: /* Main loop */
  /* Get next arg string */
  movq 8(%rsp, %r13, 8), %rsi	/* rsi = argv[r13] */
  addq $1, %r13			/* ++r13 */

  /* Check if rsi is nullptr */
  testq %rsi, %rsi /* risi & rsi */
  je done

  /* Get string length */
  xorq %rdx, %rdx		/* rdx = 0, length counter */
get_str_len:
  /* Check for null byte */
  cmpb $0, (%rsi, %rdx)		/* rsi[rdx - 0 */
  je get_str_len_done

  /* Increment length count */
  addq $1, %rdx  /* ++rdx */
  jmp get_str_len_done
get_str_len_done:


  /* syscall: write(%rdi, %rsi, %rdx)
      syscalls destroy rcx and r11
               rax used for return value

      %rdi is the file to write to
      %rsi is the start address
      %rdx is number of bytes to write
  */

  mov $STDOUT_FILENO, %rdi

  /* Neat trick--set the null byte to ' ', since we don't need it */
  /* Check if r13 == argc */
  test %r13, %r12		/* r13 & r12 */

  movb $' ', (%rsi, %rdx)	  /* rsi[rdx] = ' '*/
  addq $1, %rdx			  /* ++rdx */
write_loop:
  mov $SYS_write, %rax
  syscall
  test %rax, %rax	   /* rax & rax */
  jl error		   /* rax < 0 -> error, exit */
  leaq (%rsi, %rax), %rsi  /* rsi += rax */
  sub %rax, %rdx	   /* rdx -= rax */
  jne write_loop	   /* rdx != 0 */

jmp main_loop

done:
  /* Print out a single newline */
  mov $SYS_write, %rax
  leaq newline, %rsi
  movq $1, %rdx
  syscall
  test %rax, %rax
  jl error

  movq $SYS_exit, %rax
  xor %rdi, %rdi
  syscall

error:
  movq $SYS_exit, %rax
  movq $1, %rdi
  syscall

newline:
.byte '\n'
