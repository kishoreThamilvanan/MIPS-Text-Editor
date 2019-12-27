.data
__exp: .asciiz "Expected Byte: "
__act: .asciiz "Actual Byte:   "
__error: .asciiz "Byte Mismatch!\n"
__loc: .asciiz "Location of mismatch (row, col): ("
__comma: .asciiz ","
__rparen: .asciiz ")\n"

# include path to test case file here
# eg:
.include "highlight_test1.asm"

.text
.globl main

main:
	# Copy the initial board to MMIO region
	la $a0, __mmio_init
	li $a1, 0xffff0000
	li $a2, 4000
__loop:
	beqz $a2, __done
	lbu $t0, 0($a0)
	sb $t0, 0($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $a2, $a2, -1
	j __loop
__done:	
	
	# set the arguments to the function over here
	# eg: 
	li $a0, 0
	li $a1, 0
	li $a2, 0xFD
	li $a3, 0
	# call the function
	# eg: 
	jal highlight
	
	# load the solution board here
	# eg: 
	la $a0, __mmio_highlight_test1_sol
	# call comparaison function
	jal __mmio_cmp
	
	
	li $v0, 10
	syscall


# $a0: address to compare mmio to
__mmio_cmp:
	li $a1, 0xffff0000
	li $t8, 0
	li $t9, 4000
__mmio_cmp_loop:	
	bge $t8, $t9, __mmio_cmp_success # succefully compared all 4000 mmio bytes
	lbu $t0, 0($a0)	# load solution byte
	lbu $t1, 0($a1)	# load mmio byte
	bne $t0, $t1, __mmio_cmp_fail
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $t8, $t8, 1
	j __mmio_cmp_loop
__mmio_cmp_success:
	jr $ra

__mmio_cmp_fail:
	li $t7, 0xffff0000
	sub $a1, $a1, $t7 # number of bytes from start of mmio
	li $t7, 160
	div $a1, $t7
	mflo $t8 # LO has quotient (row number) 
	mfhi $t9 # HI has remainter (col number)
	
	# print data
	li $v0, 4
	la $a0, __error
	syscall
	la $a0, __exp
	syscall
	li $v0, 34
	move $a0, $t0
	syscall
	li $v0, 11 
	li $a0, 10
	syscall
	li $v0, 4
	la $a0, __act
	syscall
	li $v0, 34
	move $a0, $t1
	syscall
	li $v0, 11 
	li $a0, 10
	syscall
	li $v0, 4
	la $a0, __loc
	syscall
	li $v0, 1
	move $a0, $t8
	syscall
	li $v0, 4
	la $a0, __comma
	syscall
	li $v0, 1
	move $a0, $t9
	syscall
	li $v0, 4
	la $a0, __rparen
	syscall
	jr $ra

# include homework implementation
.include "hw3.asm"
