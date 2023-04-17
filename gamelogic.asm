		.text
		.globl 	u_turn
u_turn:		la	$a0, u_turn_msg		# gets users move
		li	$v0, 4
		syscall
		li	$v0, 12
		syscall
		move	$s0, $v0		# store row in $s0
		li	$v0, 5
		syscall
		move	$s1, $v0		# store col in $s1
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
									
return_main:	j	main
		
		.data
u_turn_msg:	.asciiz "It's your turn! Enter the gridspace you want to place a line at (enter a letter first then a number i.e. B0, A1, etc).\nEnter your move: "
oor_col:	.asciiz "Selected column is out of range! Make sure that your column letter is capitalized and comes before your row number. Try again.\n"
oor_row:	.asciiz "Selected row is out of range! Make sure your row number comes after your column letter. Try again.\n"
inv_space:	.asciiz "You can't place a line here because it is a dot or the center of a box! Try again.\n"
occ_space:	.asciiz "You can't place a line here because it already has a line! Try again.\n"
		.align	2
hor_line:	.ascii	"-"			# probably a better way to do this?
		.align	2
ver_line:	.ascii	"|"
		.align 2
space:		.ascii	" "