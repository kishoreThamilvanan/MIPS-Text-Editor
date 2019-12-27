##################################
# Part 1 - String Functions
##################################

is_whitespace:
	######################
	
	beqz $a0, yes_whitespace				# if(c == '\0')

	li $t0, 0xA 					# loading it with new line character
	beq $a0, $t0, yes_whitespace				# if(c == '\n')
	
	li $t0, 0x20 					# loading it with space character
	beq $a0, $t0, yes_whitespace				# if(c == ' ')
	
	li $v0, 0					# if none of the above statments are true, then set the return value to be ZERO
	j is_whitespace_end
	
	yes_whitespace: 
	  li $v0, 1
	  
	is_whitespace_end:
	######################
	jr $ra

cmp_whitespace:
	######################

	###### PROLOGUE #######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s0, 0($sp)					#store the return address
	### END OF PROLOGUE ###


	jal is_whitespace
	
	li $s0, 1
	bne $s0, $v0, no_cmp_whitespace
	
	move $a0, $a1				# preparing to check the next argument if it is a whitespace or not.
	jal is_whitespace
	bne $s0, $v0, no_cmp_whitespace
	
	#li $v0, 1				# not necessary to do that because if the above condition is false then the $v0 contains 1
	
	no_cmp_whitespace:			# we assume the $v0 will be zero because it is not a whitespace character right.
	# li $v0, 0
	
	cmp_whitespace_end:
	
	###### EPILOGUE #######
	lw $s0, 0($sp)					
	addi $sp, $sp, 4
	
	lw $ra, 0($sp)					
	addi $sp, $sp, 4				
	### END OF EPILOGUE ###
	
	######################
	jr $ra

strcpy:
	######################
	
	ble $a0, $a1, end_strcpy 
	
	move $t0, $zero				#$t0 will be the loop counter.
	strcpy_loop:
		
		bge $t0, $a2, strcpy_loop_end		
		lb $t1, 0($a0)			#loading the byte that needs to be copied into a temp register.
		sb $t1, 0($a1)			#storing the loaded byte onto the destination register bearing the address.
		
		addi $a0, $a0, 1		#moving to the next byte.
		addi $a1, $a1, 1 
		addi $t0, $t0, 1		#incrementing the counter
		j strcpy_loop
	
	strcpy_loop_end:
	end_strcpy:
	
	######################
	jr $ra

strlen:
	######################
	###### PROLOGUE #######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s0, 0($sp)					#store the s register contents
	
	addi $sp, $sp, -4 				#create space 
	sw $s1, 0($sp)					#store the s register contents
	### END OF PROLOGUE ###

	move $s0, $a0				# duplicating the String
	
	move $s1, $zero				# $s1 will be the length counter
	strlen_loop:
		
		lb $a0, 0($s0)
		
		jal is_whitespace 		# calling whitespace fucntion to check the character.
		
		beq $v0, 1, strlen_loop_end	# if it is a whitespace then return the length and exit the function.
		
		addi $s0, $s0, 1		# incremening the address of the String to go to the next character.
		addi $s1, $s1, 1		# if it is not then increment the length counter. 
		j strlen_loop
	
	strlen_loop_end:
	
	
	move $v0, $s1
	
	###### EPILOGUE #######
	lw $s1, 0($sp)				
	addi $sp, $sp, 4 			 

	lw $s0, 0($sp)				
	addi $sp, $sp, 4 			 
		
	lw $ra, 0($sp)					
	addi $sp, $sp, 4				
	### END OF EPILOGUE ###
	######################
	jr $ra

##################################
# Part 2 - vt100 MMIO Functions
##################################

set_state_color:
	######################
	
	beq $a2, 1, catogory_1			# if(catogory == 1) then jump to catogory 1
	beq $a3, 1, default_fg			# if(mode is 1) then move to update only fg
	beq $a3, 1, default_bg			# if(mode is 2) then move to update only bg

	# if none of the above statments are true then the catogoryis 0 and mode is 0
	# Default foreground, default background.
	# catogory 0, mode 0
		
	sb $a1, 0($a0)				# storing or setting the VT100 color data(argument) as received to the memeory.
	j end_set_state_color
	
	default_fg:
	# catogory 0, mode 1
	
	li $t1, 0xf				# f = 00001111
	and $t1, $a1, $t1			# trying to isolate the first four bits which represent only the foreground
	sb $t1, 0($a0)				# storing or setting only the foreground.
	j end_set_state_color
	
	default_bg:
	# catogory 0, mode 2
	
	li $t1, 0xf0				# f = 11110000
	and $t1, $a1, $t1			# trying to isolate the last four bits which represent only the background
	sb $t1, 0($a0)				# storing or setting only the background.
	j end_set_state_color
	
	
	catogory_1:
	# Highlighted foreground, highlighted background.
	
	# catogory 1, mode 0
	
	sb $a1, 1($a0)				# storing or setting the VT100 color data(argument) as received to the memeory.
	j end_set_state_color
	
	highlight_fg:
	# catogory 1, mode 1
	
	li $t1, 0xf				# f = 00001111
	and $t1, $a1, $t1			# trying to isolate the first four bits which represent only the foreground
	sb $t1, 1($a0)				# storing or setting only the foreground.
	j end_set_state_color
	
	highlight_bg:
	# catogory 1, mode 2
	
	li $t1, 0xf0				# f = 11110000
	and $t1, $a1, $t1			# trying to isolate the last four bits which represent only the background
	sb $t1, 1($a0)				# storing or setting only the background.
	j end_set_state_color
			
	end_set_state_color:
	######################
	jr $ra

save_char:
	######################
	
	lb $t1, 2($a0)				# loading the value of cursor_x from structure state 
	lb $t2, 3($a0)				# loading the value of cursor_y from structure state 
	li $t0, 0xffff0000 			# loading the initial / starting address to the register
	
	li $t3, 0x50				# loading 80	
	mul $t3, $t3, $t1			# 80*cursor_x
	add $t3, $t3, $t2			# $t3 = index; 80*cursor_x + cursor_y = index of the cursor position.
	
	add $t3, $t3, $t3			# index = index + index; (index*2)  
	add $t4, $t3, $t0			# $t4 = address of ASCII = index*2 + starting address
	
	sb $a1, ($t4)				# storing the character onto the specified address.
	
	######################
	jr $ra

reset:
	######################
	 
	lb $t6, ($a0)				# loads the first byte containing the default value of the color.
	 
	li $t5, 0xffff0000			# $t6 contains the Base/starting Address of the VT100 display
	li $t0, 25				# loading the number of rows
	li $t1, 80				# loading the number of coloumns 
	
	li $t2, 0				# i - row loop counter 
	
	reset_row_loop:
		
		li $t3, 0			# j - coloumn loop counter
		reset_column_loop:
		
			# addr = base_addr + i * num_columns * elem_size_in_bytes + j * elem_size_in_bytes
			# addr = base_addr + elem_size_in_bytes * (i * num_columns + j)
	
			mul $t4, $t2, $t1 	# i * num_columns
			add $t4, $t4, $t3 	# i * num_columns + j
			sll $t4, $t4, 1   	# 2*(i * num_columns + j)  the element's size is 2bytes because the VT100 cell has 16 bits of data color and ASCII value.
			add $t4, $t4, $t5	# $t4 = BaseAddress + 2*(i * num_columns + j)
			
			beq $a1, 1, modify_color_only
			
			sb $zero, ($t4) 	# this sets the VT100 ASCII value to null
			
			modify_color_only:
	
			sb $t6, 1($t4)		# this sets the VT100 to default value present in thr state structure.
	
			addi $t3, $t3, 1  	# j++
			blt $t3, $t1, reset_column_loop
		end_reset_column_loop:
		
		addi $t2, $t2, 1
		blt $t2, $t0, reset_row_loop
	end_reset_row_loop:
	
	######################
	jr $ra

clear_line:
	######################
	
	li $t0, 0xffff0000 			# loading the initial / starting address to the register
	
	li $t3, 80				# loading 80	
	mul $t3, $t3, $a0			# 80*byte_x
	addi $t1, $t3, 79			# 80*byte_x + 79 (we are doing this to keep the address of the last byte to break the loop when reached)
	add $t3, $t3, $a1			# $t3 = index; 80*byte_x + byte_y = index of the cursor position.
	
	add $t3, $t3, $t3			# index = index + index; (index*2)  
	add $t1, $t1, $t1			# index = index + index; (index*2) last CELL  
	
	add $t4, $t3, $t0			# $t4 = address of ASCII =  index*2 + starting address
	add $t1, $t1, $t0				#last CElls address
	
	
	clear_line_loop:
		
		sb $zero, ($t4)			# sets the ASCII value present in the current address to null.
		sb $a2, 1($t4)			# sets the color to the user specified color in the argument register.
		
		addi $t4, $t4, 2		# moving to the next VT100 cell
		
		ble $t4, $t1, clear_line_loop
	clear_line_loop_end: 	

	######################
	jr $ra

set_cursor:
	######################
	
	#A0 = STATE
	
	lb $t1, 2($a0)				# I am loading the byte_x of the state struct (this is the current x position!) 
	lb $t2, 3($a0)				# I am loading the byte_y of the state struct (this is the current y position!)
	
	li $t0, 0xffff0000 			# loading the initial / starting address to the register
	
	li $t3, 80				# loading 80	
	mul $t3, $t3, $t1			# 80*cursor_x
	add $t3, $t3, $t2			# $t3 = index; 80*cursor_x + cursor_y = index of the cursor position.
	
	sll $t3, $t3, 1				# index = index + index; (index*2)  
	add $t4, $t3, $t0			# $t4 = address of ASCII value = index*2 + starting address
       
        beq $a3, 1, skip_clearing 
	#clearing the cursor color at the original position

       	lb $t1, ($a0) 				# this loads the default color.
	sb $t1, 1($t4)				# storing the default value of the screen into the VT100 cell.
	      	
	skip_clearing: 

	li $t4, 0
        # now the $t4 contains the address of the COLOR of the new VT100 cell.          
       	sb $a1, 2($a0)				# storing the X - cursor's location to the state struct.	
	sb $a2, 3($a0)				# storing the Y - cursor's location to the state struct.
	
	# going to the VT!)) cell in the new address
	lb $t1, 2($a0)				# I am loading the byte_x of the state struct (this is the current x position!) 
	lb $t2, 3($a0)				# I am loading the byte_y of the state struct (this is the current y position!)
	
	li $t0, 0xffff0000 			# loading the initial / starting address to the register
	
	li $t3, 80				# loading 80	
	mul $t3, $t3, $t1			# 80*cursor_x
	add $t3, $t3, $t2			# $t3 = index; 80*cursor_x + cursor_y = index of the cursor position.
	
	sll $t3, $t3, 1				# index = index + index; (index*2)  
	add $t4, $t3, $t0			# $t4 = address of ASCII value = index*2 + starting address

	lb $t5, 1($t4)				# loading the value of 10001000 to invert the bits 
	xori $t5, $t5, 0x88 
	sb $t5, 1($t4)
	
	######################
	jr $ra

move_cursor:
	######################
	
	###### PROLOGUE #######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address
	#######################
	
	lb $t1, 2($a0)				# I am loading the byte_x of the state struct (this is the current x position!) 
	lb $t2, 3($a0)				# I am loading the byte_y of the state struct (this is the current y position!)
	
	# Checking for the character to be 'h'
	bne $a1, 0x68, check_for_j		# if not 'h' go check for 'j' 
	beq $t2, $zero, end_move_cursor		# if the y=0, then end the function because you can't move		
	
	addi $t2, $t2, -1			# y = y-1
	move $a1, $t1				# setting the x value to the argument
	move $a2, $t2
	li $a3, 0				# initial is set to zero
	
	# set_cursor(State, x, y-1, 0);
	jal set_cursor
	j end_move_cursor


	check_for_j:
	bne $a1, 0x6a, check_for_k		# if not 'j' go check for 'k' 
	beq $t1, 24, end_move_cursor		# if the x=24, then end the function because you can't move
	
	addi $t1, $t1, 1			# x = x+1
	move $a1, $t1				# setting the x value to the argument
	move $a2, $t2				# setting the y value to the argument
	li $a3, 0				# initial is set to zero
	
	# set_cursor(State, x+1, y, 0);
	jal set_cursor
	j end_move_cursor
	
			
	check_for_k:
	bne $a1, 0x6b, check_for_l		# if not 'k' go check for 'l' 
	beq $t1, 0, end_move_cursor		# if the x=0, then end the function because you can't move
	
	addi $t1, $t1, -1			# x = x-1
	move $a1, $t1 
	move $a2, $t2
	li $a3, 0				# initial is set to zero
	
	# set_cursor(State, x-1, y, 0);
	jal set_cursor
	j end_move_cursor
	
	
	check_for_l:
	bne $a1, 0x6c, end_move_cursor		# if not 'l' go end the function 	
	beq $t2, 79, end_move_cursor		# if the y=79, then end the function because you can't move

	addi $t2, $t2, 1			# y = y+1
	move $a2, $t2				# setting the y value
	move $a1, $t1				# setting the x value 
	li $a3, 0				# initial is set to zero
	
	# set_cursor(State, x, y+1, 0);
	jal set_cursor
	end_move_cursor:
	
	
	###### PROLOGUE #######
	lw $ra, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	#######################
	
	######################
	jr $ra

mmio_streq:
	######################
	###### PROLOGUE #######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s0, 0($sp)	
	
	addi $sp, $sp, -4 				#create space 
	sw $s1, 0($sp)	
	
	addi $sp, $sp, -4 				#create space 
	sw $s2, 0($sp)	
	
	addi $sp, $sp, -4 				#create space 
	sw $s3, 0($sp)	
	#######################
	
	move $s0, $a0 				# transferring the MMIO string to $t0
	move $s1, $a1 				# transferring the b string to $t1
	
	strcmp_loop: 
	
		lb $s2, ($s0)			# loading the first character of the MMIO string.	
		lb $s3, ($s1)			# loading the first character of the b string.
		
		# checking if the two characters are whitespace characters first.
		move $a0, $s2
		move $a1, $s3 			# placing the arguments		
		jal cmp_whitespace 		# checking if it is a whitespace character.
		beq $v0, 1, strcmp_loop_end	# if the the string reaches an end.
		
		bne $s2, $s3, str_not_equal	# if the characters are not equal then go to end of the loop.
		
		addi $s0, $s0, 2		# incrementing the address of the MMIO string which is present in MMIO Cells 
		addi $s1, $s1, 1		# incrementing the address of the b string
		j strcmp_loop
	strcmp_loop_end:
	li $v0, 1				# this indicates that the the two strings are equal
	j mmio_streq_end
	
	str_not_equal:
	li $v0, 0
	
	mmio_streq_end:
	###### EPILOGUE #######
	lw $s3, 0($sp)					#store the return address
	addi $sp, $sp, 4 
	
	lw $s2, 0($sp)					#store the return address
	addi $sp, $sp, 4 
	
	lw $s1, 0($sp)					#store the return address
	addi $sp, $sp, 4 
	
	lw $s0, 0($sp)					#store the return address
	addi $sp, $sp, 4 
	
	lw $ra, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	#######################
	
	######################
	jr $ra

##################################
# Part 3 - UI/UX Functions 
##################################

handle_nl:
	######################
	###### PROLOGUE #######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address

	addi $sp, $sp, -4 				#create space 
	sw $s0, 0($sp)					#store the return address

	addi $sp, $sp, -4 				#create space 
	sw $s1, 0($sp)					#store the return address

	addi $sp, $sp, -4 				#create space 
	sw $s2, 0($sp)					#store the return address

	#######################
	
	
	move $s0, $a0					# saving the state structure in the s register.
	lb $s1, 2($s0)					# I am loading the byte_x of the state struct (this is the current x position!) 
	lb $s2, 3($s0)					# I am loading the byte_y of the state struct (this is the current y position!)
	
	li $a1, 0xA 					# loading a new line character.
	
	jal save_char
	
	move $a0, $s1					# loading the current x value to the argument reg for calling clear line
	move $a1, $s2
	lb $a2, ($s0)					# loading the default color of the state struct.
	
	# to clear the rest of the line 
	jal clear_line				
	
	
	li $t7, 24
	beq $s1, $t7, last_line
	#setting the cursor to the next line's first cell.
	addi $s1, $s1, 1				# going to the next row
	
	last_line: 
	move $a0, $s0					# moving the state struct back to arg 0
	move $a1, $s1					# loading the current x value to the argument reg for calling clear line
	li $a2, 0					# going to the first byte of the next line
	li $a3, 1					# setting the initial to 1
	
 	#set_cursor(state, byte x+1, byte y (0), 1) 
 	jal set_cursor	
	
	###### EPILOGUE #######
	lw $s2, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s1, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 

	lw $s0, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $ra, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	#######################
	######################
	jr $ra

handle_backspace:
	######################
	###### PROLOGUE #######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s0, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s1, 0($sp)
	######################
	# going to the address of the current VT100 cell
	
	move $s0, $a0
	
	lb $t1, 2($a0)				# I am loading the byte_x of the state struct (this is the current x position!) 
	lb $t2, 3($a0)				# I am loading the byte_y of the state struct (this is the current y position!)
	
	li $t0, 0xffff0000 			# loading the initial / starting address to the register
	
	li $t3, 80				# loading 80	
	mul $t3, $t3, $t1			# 80*cursor_x
	
	addi $t6, $t3, 79			# last cell of that line 80*cursor_x + 79
	add $t3, $t3, $t2			# $t3 = index; 80*cursor_x + cursor_y = index of the cursor position.
	
	sll $t3, $t3, 1				# index = index + index; (index*2)  
	sll $t6, $t6, 1
	
	add $t4, $t3, $t0			# $t4 = address of ASCII value = index*2 + starting address
      	add $t6, $t6, $t0			# $t6 now contains the address of the very last cell.
      
      	sb $zero, ($t4)				# clearing the character present in the VT100 cell.
      	
      	li $t5, 80
      	sub $t5, $t5, $t2			# (80 - y) to determine the number of characters to be copied.
      	
      	move $t7, $t4				# moving the address presnt in t4
      	addi $t7, $t7, 2			# getting the addres of the n+1th cell.
      	
      	sll $t5, $t5, 1
      	move $a2, $t5				# moving the n to the arguemnt for calling strcpy
      	move $a0, $t7				# address of the n+1th cell from nth cell.... where n is the current cell
      	move $a1, $t4				# moving the source address to the destination string argument
      	
      	move $s1, $t6				# saving the t value that i need to use in a s register.
      	# strcpy(src string, dest string, n) = strcpy(current cell's address, current cell + 2's address, 79-y)
      	jal strcpy
      	
      	sb $zero, ($s1)				# setting the default color in the last cell.
      	lb $t7, ($s0)				# loading the default color from the state structure.
      	sb $t7, 1($s1)				# saving the color of the last cell to be the default value
      	
      	####### EPILOGUE ######
      	lw $s1, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
      	lw $s0, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $ra, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	#######################
	#######################
	jr $ra

highlight:
	######################
	
	# calculating the address of the current Cell
	move $t1, $a0				# I am loading the byte_x of the state struct (this is the current x position!) 
	move $t2, $a1				# I am loading the byte_y of the state struct (this is the current y position!)
	
	li $t0, 0xffff0001 			# loading the initial / starting address to the register
	
	li $t3, 80				# loading 80	
	mul $t3, $t3, $t1			# 80*cursor_x
	add $t3, $t3, $t2			# $t3 = index; 80*cursor_x + cursor_y = index of the cursor position.
	
	sll $t3, $t3, 1				# index = index + index; (index*2)  
	add $t4, $t3, $t0			# $t4 = address of COLOR value = index*2 + starting address
       
        li $t5, 0				# $t5 will be the loop counter.
	highlight_n:
		
		sb $a2, ($t4)			# storing the argument color on to the VT100 cell.
	
		addi $t4, $t4, 2
		addi $t5, $t5, 1
		bgt $a3, $t5, highlight_n
		
	highlight_n_end:

	######################
	jr $ra

highlight_all:
	######################
	###### PROLOGUE ######
	addi $sp, $sp, -4 				#create space 
	sw $ra, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s0, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s1, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s2, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s3, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s4, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s5, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s6, 0($sp)					#store the return address
	
	addi $sp, $sp, -4 				#create space 
	sw $s7, 0($sp)					#store the return address
	######################

	move $s3, $a0					# saving the color argument which is passed to this function
	move $s4, $a1					# saving the String[] Dictionary argument which is passed to this function
	move $s7, $a1
	
	li $s6, 0xffff0fa0				# address of the very last VT100 cell of the display.
	#addi $s6, $s6, -1				# address of the last byte minus 1
	
	# calculating the address of the 
	li $t1, 0 				# x=0 startin from the very first byte of the program 
	li $t2, 0				# y=0
	li $s5, 0				# counter to keep track of the x and y
	
	li $t0, 0xffff0000 			# loading the initial / starting address to the register
	
	li $t3, 80				# loading 80	
	mul $t3, $t3, $t1			# 80*cursor_x
	add $t3, $t3, $t2			# $t3 = index; 80*cursor_x + cursor_y = index of the cursor position.
	
	sll $t3, $t3, 1				# index = index + index; (index*2)  
	add $s0, $t3, $t0			# $t4 = address of ASCII value = index*2 + starting address
       
	highlight_while:
		blt  $s6, $s0, highlight_while_end	# $t5 is last address, $t4 is the check in if the current address is the very last address
		
		li $t0, 2000
		bgt $s5, $t0, highlight_while_end	# the counter should be less than the total number of cells present in the whole display.
		whitespace_while:			# this is a whitespace checking loop  
			
			 lb $a0, ($s0) 			# loading the character from the current address, the $t4 keeps ranging from the very first byte to the very last byte.
			 jal is_whitespace		# checks if the passed character is a whitespace character or not.
			 beq $v0, 0, whitespace_while_end	# if it is not a whitespace character then, skip the whitespace checking loop
			 
			# move to next MMIO cell
			addi $s0, $s0, 2		# going to the next MMIO cell
			addi $s5, $s5, 1		# keeping track of the x and y by counting the cell number
			
			li $t0, 2000
			bgt $s5, $t0, highlight_while_end	# the counter should be less than the total number of cells present in the whole display.
		
      			j whitespace_while
		whitespace_while_end:
		
		# saving the current cell's position
		move $s1, $s0				# moving the $s0 whihc ocntains the address of the current cell to a s reg to save it.
		
		# checking each word in the dictionary to highlight.
		move $s4, $s7				# reseting the address of the dictionary argument
		dictionary_for_loop:
			lw $s2, ($s4)			# loading the word
			beqz $s2, dictionary_for_loop_end	# if you reach the null character, it means you have reached the very last word.
			
			move $a0, $s0			# moving the MMIO cell string onto the arg 1
			move $a1, $s2			# moving the string obtained to the 2nd arg
			
			jal mmio_streq			# calling the string equal function !!
			bne $v0, 1, skip_highlight_word
			
			move $a0, $s2
			jal strlen			# getting the word's length 
			# $v0 contains the length of the string.
			
			# now highlight the cells till the length of the string
		
			# calculating the x and y byte from the counter 
			li $t7, 80
			div $s5, $t7			# HI contains the remainder = coloumns && LO contains the quotient = row
			mfhi $a1			# loading the coloumn number or the byte y 
			mflo $a0			# loading the row number or the byte x
		
			move $a2, $s3			# load the color
			move $a3, $v0 			# load the str lenth that is the number of bytes it has to highlight.
			jal highlight			# call highlight fucntion
			j dictionary_for_loop_end	# if highlighted then just leave the highlight loop.
					
			skip_highlight_word:
		
			addi $s4, $s4, 4		# going to the next word 
			j dictionary_for_loop
		dictionary_for_loop_end:

		
		# setting the address to current cell position
		move $s0, $s1 
		
		not_whitespace_while:			# this is a whitespace checking loop  
			
			 lb $a0, ($s0) 			# loading the character from the current address, the $t4 keeps ranging from the very first byte to the very last byte.
			 jal is_whitespace		# checks if the passed character is a whitespace character or not.
			 beq $v0, 1, not_whitespace_while_end	# if it is not a whitespace character then, skip the whitespace checking loop
			 
			# move to next MMIO cell
			addi $s0, $s0, 2		# going to the next MMIO cell
      			addi $s5, $s5, 1		# keeping track of the x and y by counting the cell number
      			
      			li $t0, 2000
			bgt $s5, $t0, highlight_while_end	# the counter should be less than the total number of cells present in the whole display.
		
			j not_whitespace_while
		not_whitespace_while_end:
		j highlight_while
	highlight_while_end:
	####### EPILOGUE ######
	lw $s7, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s6, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s5, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s4, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s3, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s2, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $s1, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
      	lw $s0, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	
	lw $ra, 0($sp)					#store the return address
	addi $sp, $sp, 4 				#create space 
	#######################
	######################
	jr $ra
