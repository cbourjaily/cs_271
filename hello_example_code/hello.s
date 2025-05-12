# Linux standard streams
.equ STDIN_FILENO, 0
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2

# Linux 64-bit system call numbers
.equ SYS_read, 0
.equ SYS_write, 1
.equ SYS_exit, 60

.global _start
.type _start, @function
_start:
mov $STDOUT_FILENO, %edi
mov $s1, %esi
mov $sizeof_s1, %edx
mov $SYS_write, %eax
syscall

mov $5, %edi
mov $2, %esi
call ipow

mov %eax, %edi
mov $SYS_exit, %eax
syscall

# ipow
# Computes integer power of a number
# Arguments:
#	%edi, base
#	%esi, exponent
#
# Returns:
#	%eax, base ** exponent
.type ipow, @function
ipow:
	mov $1, %eax
	cmp $0, %esi
	je 2f # Jump forward to label 2 if exponent is 0
	jl 3f # Jump forward to label 3 if exponent is <0
1:
	imul %edi
	sub $1, %esi
	jnz 1b
2:
	ret
3:
	mov $0, %eax
	ret

.section .rodata
s1:
.asciz "Hello, World!\n"
.equ sizeof_s1, . - s1
