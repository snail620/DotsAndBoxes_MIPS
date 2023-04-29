		.text
		.globl c_turn
		.macro set_border_count (%box_line, %box_border_array)
		la $t0, %box_line
		addi $t0, $t0, 1		# increment by 1 to reach the center of the first box
		la $t1, %box_border_array
		lbu $t6, hor_line($zero)	# $t6 contains the horizontal line
		lbu $t7, ver_line($zero)	# $t7 contains the vertical line
		add $t8, $zero, $zero		# initialize t8 to 0 (t8 is the loop counter)
		
count_start:	add $t2, $zero, $zero		# initialize t2 to 0 (t2 is the border counter)	
first_check:	lbu $t3, -16($t0)		# check whether the line on top is present
		bne $t3, $t6, second_check
		addi $t2, $t2, 1		# increment border counter
second_check:	lbu $t3, -1($t0)		# check whether the line on the left is present
		bne $t3, $t7, third_check
		addi $t2, $t2, 1		# increment border counter
third_check:	lbu $t3, 16($t0)		# check whether the line on bottom is present
		bne $t3, $t6, fourth_check
		addi $t2, $t2, 1		# increment border counter
fourth_check:	lbu $t3, 1($t0)			# check whether the line on the right is present
		bne $t3, $t7, end_of_check
		addi $t2, $t2, 1		# increment border counter
		
end_of_check:	sw $t2, ($t1)			# store border count in array
		addi $t8, $t8, 1		# increment loop counter
		addi $t0, $t0, 2		# move to next box center in board line
		addi $t1, $t1, 4		# move to next array location
		blt $t8, 7, count_start		# loop statement
		.end_macro
		
		.macro check_for_threes (%box_line, %box_border_array)
		la $t0, %box_line
		move $t2, $t0			# set t2 to %box_line
		addi $t0, $t0, 1		# increment by 1 to reach the center of the first box
		la $t1, %box_border_array
		move $t4, $t1			# set t1 to %box_border array
		lbu $t6, hor_line($zero)	# $t6 contains the horizontal line
		lbu $t7, ver_line($zero)	# $t7 contains the vertical line
		add $t8, $zero, $zero		# initialize t8 to 0 (t8 is the loop counter)
		la $t9, board			# $t9 contains the address of the board
		
loop_start:	sll $t8, $t8, 2
		lw $t5, %box_border_array($t8)
		srl $t8, $t8, 2
		bne $t5, 3, end_of_checks
		
search_start:	
top_check:	lbu $t3, -16($t0)		# check whether the line on top is present
		beq $t3, $t6, left_check
		addi $t4, $t0, -16
		sb $t6, ($t4)
		
left_check:	lbu $t3, -1($t0)		# check whether the line on the left is present
		beq $t3, $t7, bottom_check
		addi $t4, $t0, -1
		sb $t7, ($t4)
		
bottom_check:	lbu $t3, 16($t0)		# check whether the line on bottom is present
		beq $t3, $t6, right_check
		addi $t4, $t0, 16
		sb $t6, ($t4)
		
right_check:	lbu $t3, 1($t0)			# check whether the line on the right is present
		beq $t3, $t7, update_row_col
		addi $t4, $t0, 1
		sb $t7, ($t4)
		
update_row_col:	sub $t5, $t4, $t9
		srl $a0, $t5, 4
		and $a1, $t5, 15
		j end
		
end_of_checks:	
		addi $t8, $t8, 1		# increment loop counter
		addi $t0, $t0, 2		# move to next box center in board line
		addi $t1, $t1, 4		# move to next array location
		blt $t8, 7, loop_start		# loop statement
loop_break:
		.end_macro
		
c_turn:		set_border_count (box_line_1, box_borders_1)
		set_border_count (box_line_2, box_borders_2)
		set_border_count (box_line_3, box_borders_3)
		set_border_count (box_line_4, box_borders_4)
		set_border_count (box_line_5, box_borders_5)
		
		check_for_threes (box_line_1, box_borders_1)
		check_for_threes (box_line_2, box_borders_2)
		check_for_threes (box_line_3, box_borders_3)
		check_for_threes (box_line_4, box_borders_4)
		check_for_threes (box_line_5, box_borders_5)
		
		# Make random move
start_random:	li $a1, 10		# number of rows
		li $v0, 42  		# generate the random number
		syscall
		move $s0, $a0
		and $a0, 1
		beq $a0, 1, z_ind_odd_row
		li $a1, 8		# number of columns/2
		li $v0, 42  		# generate the random number
		syscall
		sll $a0, $a0, 1
		addi $a0, $a0, 1
		j check_result
z_ind_odd_row:	li $a1, 8		# number of columns/2
		li $v0, 42  		# generate the random number
		syscall
		sll $a0, $a0, 1
check_result:	move $s1, $a0
		andi	$t0, $s0, 1		# get LSB of row and col to determine parity
		andi	$t1, $s1, 1
		bne	$t0, $t1, valid_space	# branch if space is valid (parities of row and col are different)
		j start_random
		syscall
		j	u_turn
valid_space:	sll	$t2, $s0, 4		# calculate displacement address of byte to update
		add	$t2, $t2, $s1
		lbu	$t3, board($t2)
		lbu	$t4, space
		beq	$t3, $t4, empty_space	# branch if space to place line is currently empty
		j	start_random
		syscall
		j	u_turn
empty_space:	beq	$t0, $zero, even_row
		lbu	$t3, ver_line
		j	update_board
even_row:	lbu	$t3, hor_line
update_board:	sb	$t3, board($t2)		# update byte at appropriate address

		# before jumping to check_boxes
		# store row number in $a0 and col number in $a1
		move	$a0, $s0		# set args and call check_boxes
		move	$a1, $s1
		j	check_boxes
		

		
fill_3_unit:	# complete boxes where number of sides = 3

end:		j check_boxes

		.data
		# box_borders_n: the number of borders for each box on line n
		.align 4
		box_borders_1: .space 28
		box_borders_2: .space 28
		box_borders_3: .space 28
		box_borders_4: .space 28
		box_borders_5: .space 28
