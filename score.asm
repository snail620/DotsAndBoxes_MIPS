		.text
		.globl check_boxes
		# before jumping to check_boxes
		# store row number in $a0 and col number in $a1
		
check_boxes:	sll	$s0, $a0, 4
		add	$s0, $s0, $a1
		la	$t0, board
		add	$s0, $s0, $t0			# calculate address of the newly placed line and store in $s0
		li	$s1, 0				# $s1 stores the points gained on this turn and is initialized to zero
		lbu	$s2, space			# set $s2 to value of space character
		lw	$s3, turn			# load turn into $s3
		beq	$s3, $zero, is_user		# load char to replace center of box with if a box is completed
							# store in $s4
		lbu	$s4, c_box
		j	check_even
is_user:	lbu	$s4, u_box
check_even:	andi	$t1, $a0, 1
		beq	$t1, $zero, is_hor		# branch to is_hor if the row number is even 
							# and therefore the line placed at that space is horizontal
		# check if the box behind the line is full
		add	$t0, $s0, -1			# set $t0 to the address of the center of the box
							# to the left of the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, check_forward		# branch to check_forward if $t0 does not contain a box center
		lbu	$t1, -16($t0)
		beq	$t1, $s2, check_forward		# branch to check_forward if the space above the box center is empty
		lbu	$t1, -1($t0)
		beq	$t1, $s2, check_forward		# branch to check_forward if the space before the box center is empty
		lbu	$t1, 16($t0)
		beq	$t1, $s2, check_forward		# branch to check_forward if the space below the box center is empty
		sb	$s4, ($t0)			# update center of box if all lines surrounding the center are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round
		
		# check if the box in front of the line is full				
check_forward:	add	$t0, $s0, 1			# set $t0 to the address of the center of the box
							# to the right of the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, update_score		# branch to check_forward if $t0 does not contain a box center
		lbu	$t1, -16($t0)
		beq	$t1, $s2, update_score		# branch to check_forward if the space above the box center is empty
		lbu	$t1, 1($t0)
		beq	$t1, $s2, update_score		# branch to check_forward if the space before the box center is empty
		lbu	$t1, 16($t0)
		beq	$t1, $s2, update_score		# branch to check_forward if the space below the box center is empty
		sb	$s4, ($t0)			# update center of box if all lines surrounding the center are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round
		j	update_score
		
		# check if the box above the line is full
is_hor:		add	$t0, $s0, -16			# set $t0 to the address of the center of the box
							# to the right of the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, check_below		# branch to check_forward if $t0 does not contain a box center
		lbu	$t1, -1($t0)
		beq	$t1, $s2, check_below		# branch to check_forward if the space above the box center is empty
		lbu	$t1, -16($t0)
		beq	$t1, $s2, check_below		# branch to check_forward if the space before the box center is empty
		lbu	$t1, 1($t0)
		beq	$t1, $s2, check_below		# branch to check_forward if the space below the box center is empty
		sb	$s4, ($t0)			# update center of box if all lines surrounding the center are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round

		# check if the box below the line is full
check_below:	add	$t0, $s0, 16			# set $t0 to the address of the center of the box
							# to the right of the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, update_score		# branch to check_forward if $t0 does not contain a box center
		lbu	$t1, -1($t0)
		beq	$t1, $s2, update_score		# branch to check_forward if the space above the box center is empty
		lbu	$t1, 16($t0)
		beq	$t1, $s2, update_score		# branch to check_forward if the space before the box center is empty
		lbu	$t1, 1($t0)
		beq	$t1, $s2, update_score		# branch to check_forward if the space below the box center is empty
		sb	$s4, ($t0)			# update center of box if all lines surrounding the center are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round

		# update score and turn in memory
update_score:	beq	$s1, $zero, no_points		# branch to no_points if no points were scored
		bne	$s3, $zero, is_comp		# branch to is_comp if it's the computer's turn
		
		lw	$t0, u_score			# load the user's score into memory
		add	$t0, $t0, $s1			# add points gained to user's score
		sw	$t0, u_score			# store sum back to memory in u_score
		j	main
		
is_comp:	lw	$t0, c_score			# load the computer's score into memory
		add	$t0, $t0, $s1			# add points gained to computer's score
		sw	$t0, c_score			# store sum back to memory in c_score
		j	main
				
no_points:	li	$t0, 1
		nor	$s3, $s3, $t0			# flip the turn and store it to memory
		sw	$s3, turn
		j	main
		
		.data
u_box:		.ascii	"U"
		.align 	2
c_box:		.ascii	"C"
