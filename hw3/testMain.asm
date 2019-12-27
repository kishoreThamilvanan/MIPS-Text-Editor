.include "hw3_helpers.asm"
.include "hw3.asm"
.include "hw3_dict.asm"

.data
character_prompt1: .asciiz "String which is to be copied: "
character_prompt2: .asciiz "String where it has to be copied: "
character_prompt3: .asciiz "copied string after the function call: "
notWhitespace: .asciiz "Not! a whitespace character!"
yesWhitespace: .asciiz "yes! a whitespace character!"
part1cTest1Str: .ascii "Cats and Dogs"
part1cSpaceNoChange: .space 40
part1dTest1Str: .asciiz "Hi CSE 220...."
part1dTest2Str: .asciiz "HiCSE220....\0"
part1dTest3Str: .asciiz " HiCSE220...."
part1dTest4Str: .asciiz "H\niCSE220...."
part1dTest5Str: .asciiz "HiCSE220....\n"
newline: .asciiz "\n"



.globl main
.text
main:
testing_whitespace_method:

	
li $t5, 0xffff0000			# $t6 contains the Base/starting Address of the VT100 display
	li $t0, 25				# loading the number of rows
	li $t1, 80				# loading the number of coloumns 
	
	li $t2, 0				# i - row loop counter 
	
	reset_row_loop1:
		
		li $t3, 0			# j - coloumn loop counter
		reset_column_loop1:
		
			# addr = base_addr + i * num_columns * elem_size_in_bytes + j * elem_size_in_bytes
			# addr = base_addr + elem_size_in_bytes * (i * num_columns + j)
	
			mul $t4, $t2, $t1 	# i * num_columns
			add $t4, $t4, $t3 	# i * num_columns + j
			sll $t4, $t4, 1   	# 2*(i * num_columns + j)  the element's size is 2bytes because the VT100 cell has 16 bits of data color and ASCII value.
			add $t4, $t4, $t5	# $t4 = BaseAddress + 2*(i * num_columns + j)
			
			beq $a1, 1, modify_color_only1
			
			sb $zero, ($t4) 	# this sets the VT100 ASCII value to null
			
			modify_color_only1:
	
			sb $t6, 1($t4)		# this sets the VT100 to default value present in thr state structure.
	
			addi $t3, $t3, 1  	# j++
			blt $t3, $t1, reset_column_loop1
		end_reset_column_loop1:
		
		addi $t2, $t2, 1
		blt $t2, $t0, reset_row_loop1
	end_reset_row_loop1:
	
	

exit:
	li $v0, 10
	syscall
