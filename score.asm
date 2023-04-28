		.text
		.globl check_boxes
		# before jumping to check_boxes
		# store row number in $a0 and col number in $a1
		# row number should be between 0 and 10, col number should be between 0 and 14
		
check_boxes:	sll	$s0, $a0, 4			# convert row number into byte address offset by multiplying 
							# by 16 and store in $s0
		add	$s0, $s0, $a1			# add col number to $s0 to get full byte address offset
		la	$t0, board			# load address of the label board
		add	$s0, $s0, $t0			# calculate full address of the newly placed line and store in $s0
		li	$s1, 0				# $s1 stores the points gained on this turn and is initialized to zero
		lbu	$s2, space			# set $s2 to value of space character
		lw	$s3, turn			# load turn into $s3
		
		# determine whether it is the user's or the computer's turn, then load the appropriate character
		# into $s4 - this character replaces the space at the center of a box when it is claimed
		beq	$s3, $zero, is_user		# if turn is 0, branch to is_user
		lbu	$s4, c_box			# it is the computer's turn, so load 'C'
		j	check_even
is_user:	lbu	$s4, u_box			# it is the user's turn, so load 'U'
		
		# determine whether line is vertical or horizontal and perform the appropriate box checking
check_even:	andi	$t1, $a0, 1
		beq	$t1, $zero, is_hor		# branch to is_hor if the row number is even 
							# and therefore the line placed at that space is horizontal
		
		# beginning of checking for completed boxes if the line placed is vertical
		# check if the box behind the line is full
		addi	$t0, $s0, -1			# set $t0 to the address of the char that is
							# directly before the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, check_forward		# branch to check_forward if the char at $t0 
							# is not the center of a box (isn't a space character)
		lbu	$t1, -16($t0)
		beq	$t1, $s2, check_forward		# branch to check_forward if the space above the box center is empty
		lbu	$t1, -1($t0)
		beq	$t1, $s2, check_forward		# branch to check_forward if the space left of the box center is empty
		lbu	$t1, 16($t0)
		beq	$t1, $s2, check_forward		# branch to check_forward if the space below the box center is empty
		
		sb	$s4, ($t0)			# update center of box to be claimed
							# because all surrounding lines are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round
		
		# check if the box in front of the line is full				
check_forward:	addi	$t0, $s0, 1			# set $t0 to the address of the char that is
							# directly after the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, update_score		# branch to update_score if the char at $t0 
							# is not the center of a box (isn't a space character)
		lbu	$t1, -16($t0)
		beq	$t1, $s2, update_score		# branch to update_score if the space above the box center is empty
		lbu	$t1, 1($t0)
		beq	$t1, $s2, update_score		# branch to update_score if the space right of the box center is empty
		lbu	$t1, 16($t0)
		beq	$t1, $s2, update_score		# branch to update_score if the space below the box center is empty
		
		sb	$s4, ($t0)			# update center of box to be claimed
							# because all surrounding lines are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round
		
		j	update_score			# jump to update_score
		
		# beginning of checking for completed boxes if the line placed is horizontal
		# check if the box above the line is full
is_hor:		addi	$t0, $s0, -16			# set $t0 to the address of the center of the box
							# that lies above the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, check_below		# branch to check_below if the char at $t0 
							# is not the center of a box (isn't a space character)
		lbu	$t1, -1($t0)
		beq	$t1, $s2, check_below		# branch to check_below if the space left of the box center is empty
		lbu	$t1, -16($t0)
		beq	$t1, $s2, check_below		# branch to check_below if the space above the box center is empty
		lbu	$t1, 1($t0)
		beq	$t1, $s2, check_below		# branch to check_below if the space right of the box center is empty
		
		sb	$s4, ($t0)			# update center of box to be claimed
							# because all surrounding lines are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round

		# check if the box below the line is full
check_below:	addi	$t0, $s0, 16			# set $t0 to the address of the center of the box
							# that lies below the line
		lbu	$t1, ($t0)
		bne	$t1, $s2, update_score		# branch to update_score if the char at $t0 
							# is not the center of a box (isn't a space character)
		lbu	$t1, -1($t0)
		beq	$t1, $s2, update_score		# branch to update_score if the space left of the box center is empty
		lbu	$t1, 16($t0)
		beq	$t1, $s2, update_score		# branch to update_score if the space below the box center is empty
		lbu	$t1, 1($t0)
		beq	$t1, $s2, update_score		# branch to update_score if the space right of the box center is empty
		
		sb	$s4, ($t0)			# update center of box to be claimed
							# because all surrounding lines are filled
		addi	$s1, $s1, 1			# add 1 to the score gained this round

		# update turn or appropriate score in memory
update_score:	beq	$s1, $zero, no_points		# branch to no_points if no points were scored
							# if points were scored:
		bne	$s3, $zero, is_comp		# branch to is_comp if it is the computer's turn
		
		# update the score when the user scores
		lw	$t0, u_score			# load the user's score into memory
		add	$t0, $t0, $s1			# add points gained to user's score
		sw	$t0, u_score			# store sum back to memory in u_score
		# play user score sound
		li	$a2, 121			# set sound effect
		li	$a0, 99				# set pitch (higher for user score)
		li	$a1, 1000			# set duration (1 second)
		li	$a3, 127			# set volume (max folume)
		li	$v0, 31
		syscall
		j	main				# return to main
		
		# update the score when the computer scores
is_comp:	lw	$t0, c_score			# load the computer's score into memory
		add	$t0, $t0, $s1			# add points gained to computer's score
		sw	$t0, c_score			# store sum back to memory in c_score
		# play computer score sound
		li	$a2, 121			# set sound effect
		li	$a0, 71				# set pitch (lower for computer score)
		li	$a1, 1000			# set duration (1 second)
		li	$a3, 127			# set volume (max folume)
		li	$v0, 31
		syscall
		j	main				# return to main
		
		# update turn when no points have been scored
no_points:	li	$t0, 1
		nor	$s3, $s3, $t0			# flip the turn
		sw	$s3, turn			# store the flipped turn in memory at turn
		# play place line sound
		li	$a2, 127			# set sound effect
		li	$a0, 105			# set pitch
		li	$a1, 1000			# set duration (1 second)
		li	$a3, 127			# set volume (max volume)
		li	$v0, 31
		syscall
		j	main				# return to main
		
		.data
u_box:		.ascii	"U"
		.align 	2
c_box:		.ascii	"C"
