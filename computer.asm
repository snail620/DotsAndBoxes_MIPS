		.text
		.globl c_turn
		.macro set_border_count (%board_line, %box_border_array)
		la $t0, (%board_line)
		addi $t0, $t0, 1		# increment by 1 to reach the center of the first box
		la $t1, (%box_border_array)
		addi $t2, $zero, $zero		# initialize t2 to 0 (t2 is the border counter)
		lbu $t6, hor_line($zero)	# $t6 contains the horizontal line
		lbu $t7, ver_line($zero)	# $t7 contains the vertical line
		addi $t8, $zero, $zero		# initialize t8 to 0 (t8 is the loop counter)
count_start:		
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
		
c_turn:		

		.data
		# box_borders_n: the number of borders for each box on line n
		box_borders_1: .space 20
		box_borders_2: .space 20
		box_borders_3: .space 20
		box_borders_4: .space 20
		box_borders_5: .space 20