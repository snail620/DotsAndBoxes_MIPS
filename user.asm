		.text
		.globl 	u_turn
u_turn:		li	$v0, 12			# get user's move
		syscall
		move	$s0, $v0		# store row in $s0
		li	$v0, 5
		syscall
		move	$s1, $v0		# store col in $s1
		addi	$s1, $s1, -1		# subtract 1 from col to simplify byte address calculation
		sub	$s0, $s0, $s2		# convert from row letter into row number
						# col_bias is still saved in $s2
		
		li	$v0, 4			# check for valid input
		li	$t0, 15
		bltu	$s1, $t0, valid_col	# branch if column is valid (in range)
		la	$a0, oor_col
		syscall
		j	u_turn
valid_col:	li	$t0, 11
		bltu	$s0, $t0, valid_row	# branch if row is valid (in range)
		la	$a0, oor_row
		syscall
		j	u_turn
valid_row:	andi	$t0, $s0, 1		# get LSB of row and col to determine parity
		andi	$t1, $s1, 1
		bne	$t0, $t1, valid_space	# branch if space is valid (parities of row and col are different)
		la	$a0, inv_space
		syscall
		j	u_turn
valid_space:	sll	$t2, $s0, 4		# calculate displacement address of byte to update
		add	$t2, $t2, $s1
		lbu	$t3, board($t2)
		lbu	$t4, space
		beq	$t3, $t4, empty_space	# branch if space to place line is currently empty
		la	$a0, occ_space
		syscall
		j	u_turn
empty_space:	beq	$t0, $zero, even_row
		lbu	$t3, ver_line
		j	update_board
even_row:	lbu	$t3, hor_line
update_board:	sb	$t3, board($t2)		# update byte at appropriate address

		move	$a0, $s0		# set args and call check_boxes
		move	$a1, $s1
		j	check_boxes
		
# return_main:	j	main
		
		.data
oor_col:	.asciiz "Selected column is out of range! Make sure that your column number is between 1 and 15. Try again.\nEnter your move: "
oor_row:	.asciiz "Selected row is out of range! Make sure your row letter is a capital letter between A and K. Try again.\nEnter your move: "
inv_space:	.asciiz "You can't place a line here because it is a dot or the center of a box! Try again.\nEnter your move: "
occ_space:	.asciiz "You can't place a line here because it already has a line! Try again.\nEnter your move: "

