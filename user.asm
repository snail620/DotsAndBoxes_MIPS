		.text
		.globl 	u_turn
		# get user's move
u_turn:		li	$v0, 12			# get row letter
		syscall
		move	$s0, $v0		# store row letter in $s0
		li	$v0, 5			# get col number
		syscall
		move	$s1, $v0		# store col number in $s1
		addi	$s1, $s1, -1		# subtract 1 from col to simplify byte address calculation
		sub	$s0, $s0, $s2		# convert from row letter into row number by
						# subtracting col_bias from row letter
						# col_bias is still saved in $s2
		
		# validate input
		li	$v0, 4			# set $v0 in preparation for displaying error messages
		
		# check if column is in range
		li	$t0, 15			# load one greater than max col number into $t0
		bltu	$s1, $t0, valid_col	# branch if column is in range
		
		la	$a0, oor_col		# display out of range col error message
		syscall
		j	err_sound
		
		# check if row is in range
valid_col:	li	$t0, 11			# load one greater than max row number into $t0
		bltu	$s0, $t0, valid_row	# branch if row is in range
		
		la	$a0, oor_row		# display out of range row error message
		syscall
		j	err_sound
		
		# check if space is playable (not a dot or the center of a box)
valid_row:	andi	$t0, $s0, 1		# get LSB of row and col to determine parity
		andi	$t1, $s1, 1
		bne	$t0, $t1, valid_space	# branch if space is valid (parities of row and col are different)
		
		la	$a0, inv_space		# display invalid space error message
		syscall
		j	err_sound
		
		# check if space is available (not already filled with a line)
valid_space:	sll	$t2, $s0, 4		# calculate byte address of character to update
		add	$t2, $t2, $s1
		lbu	$t3, board($t2)		# load the character currently at that address into $t3
		lbu	$t4, space		# load the space character (" ") into $t4
		beq	$t3, $t4, empty_space	# branch if character currently at the address is a space
		
		la	$a0, occ_space		# display occupied space error message
		syscall
		j	err_sound
		
		# determine whether line is a vertical or horizontal line
empty_space:	beq	$t0, $zero, even_row	# if the row number is even, branch to even_row
		lbu	$t3, ver_line		# row is odd, so load ver_line character into $t3
		j	update_board
even_row:	lbu	$t3, hor_line		# row is even, so load hor_line character into $t3

update_board:	sb	$t3, board($t2)		# update board by changing character at the byte address
						# to the appropriate line
		
		move	$a0, $s0		# set argument registers with row and col numbers
		move	$a1, $s1
		j	check_boxes		# jump to check_boxes
		
		# play error sound
err_sound:	li	$a2, 124		# set sound effect
		li	$a0, 105		# set pitch
		li	$a1, 400		# set duration (400 milliseconds)
		li	$a3, 127		# set volume (max volume)
		li	$v0, 31
		syscall
		j	u_turn			# jump back to u_turn to let user enter a new move
		
		.data
oor_col:	.asciiz "Selected column is out of range! Make sure that your column number is between 1 and 15. Try again.\nEnter your move: "
oor_row:	.asciiz "Selected row is out of range! Make sure your row letter is a capital letter between A and K. Try again.\nEnter your move: "
inv_space:	.asciiz "You can't place a line here because it is a dot or the center of a box! Try again.\nEnter your move: "
occ_space:	.asciiz "You can't place a line here because it already has a line! Try again.\nEnter your move: "

