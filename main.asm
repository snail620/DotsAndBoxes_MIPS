		.text
		.globl 	main
		
main:		# display the current board
		la	$a0, new_line
		li	$v0, 4
		syscall
		li	$t0, 0			# initialize counter
		li	$t2, 11			# set end condition for looping
		lw	$s2, col_bias		# store col_bias as a saved temp in $s2
		li	$v0, 4
display_board:	add	$a0, $t0, $s2		# calculate row letter and store in $a0 to print
		li	$v0, 11
		syscall
		la	$a0, space		# print a space
		li	$v0, 4
		syscall
		sll	$t1, $t0, 4
		la	$a0, board($t1)		# print corresponding row in board and new line
		syscall
		la	$a0, new_line
		syscall
		addi	$t0, $t0, 1		# increment counter
		blt	$t0, $t2, display_board	# loop if counter is less than 11
		
		la	$a0, board_footer1	# print footers
		syscall
		la	$a0, board_footer2
		syscall
		
		# play test sound
		#li	$a2, 115
		#li	$a0, 45
		#li	$a1, 2000
		#li	$a3, 127
		#li	$v0, 33
		#syscall
		
				
		# display scores
		la	$a0, display_u_score
		li	$v0, 4
		syscall
		lw	$t0, u_score
		move	$a0, $t0
		li	$v0, 1
		syscall
		la	$a0, new_line
		li	$v0, 4
		syscall
		la	$a0, display_c_score
		syscall
		lw	$t1, c_score
		move	$a0, $t1
		li	$v0, 1
		syscall
		la	$a0, new_line
		li	$v0, 4
		syscall
		syscall
		
check_end:	add	$t2, $t0, $t1		# check if sum of user and comp score is 35
		li	$t3, 35
		bge	$t2, $t3, game_end
		
	#	li	$a0, 1000		# pause for user to see updated score and what moves were made
						# consider changing this to only run before computer's turn
	#	li	$v0, 32
	#	syscall
		
		li	$v0, 4			# prepare for print string syscall
		lw	$t0, turn		# determine whose turn it is and jump accordingly
		bne	$t0, $zero, else_turn
		la	$a0, u_turn_msg		# display u_turn_msg
		syscall
		j	u_turn
		
else_turn:	la	$a0, c_turn_msg		# display u_turn_msg
		syscall
		j	u_turn			# in the real program, jump to computer's turn subroutine in other file
		
game_end:	blt	$t0, $t1, c_win		# check for who won the game
		
u_win:		la	$a0, u_win_msg
		li	$v0, 4
		syscall
		# play win sound
		# TODO find a good sound
		li	$a2, 124
		li	$a0, 100
		li	$a1, 1000
		li	$a3, 127
		j	end
		
c_win:		la	$a0, c_win_msg
		li	$v0, 4
		syscall
		# play lose sound
		li	$a2, 115
		li	$a0, 45
		li	$a1, 2000
		li	$a3, 127
		
end:		#li	$v0, 33
		#syscall				# play sound
		li	$v0, 10
		syscall

		.data
		.globl	board
		.globl	box_line_1
		.globl	box_line_2
		.globl	box_line_3
		.globl	box_line_4
		.globl	box_line_5
		.globl	turn
		.globl	u_score
		.globl	c_score
		.globl	hor_line
		.globl	ver_line
		.globl	space
		.asciiz "+++++++++++++++"	# this is stored in memory to ensure that box checking logic works              "
board:		.asciiz	"+ + + + + + + +"
box_line_1:	.asciiz "               "
		.asciiz	"+ + + + + + + +"
box_line_2:	.asciiz "               "
		.asciiz	"+ + + + + + + +"
box_line_3:	.asciiz "               "
		.asciiz	"+ + + + + + + +"
box_line_4:	.asciiz "               "
		.asciiz	"+ + + + + + + +"
box_line_5:	.asciiz "               "
		.asciiz	"+ + + + + + + +"
		.asciiz "+++++++++++++++"
board_footer1:	.asciiz "  123456789111111\n"
board_footer2:	.asciiz	"           012345\n\n"
display_u_score:.asciiz "Your score: "
display_c_score:.asciiz "Computer's score: "
u_turn_msg:	.asciiz "It's your turn! Enter the gridspace you want to place a line at (enter a letter first then a number i.e. B1, A2, etc).\nEnter your move: "
c_turn_msg:	.asciiz "It's the computer's turn! Wait for it to make a move.\nDEBUG Enter your move: "
						# this message may not be needed in the final program
u_win_msg:	.asciiz "You won the game! Congratulations!\n"
c_win_msg:	.asciiz "The computer won the game! Better luck next time!\n"
tie_msg:	.asciiz "The game was a draw!\n"
new_line:	.asciiz "\n"
		.align	2
col_bias:	.ascii	"A"			# used to convert row letter into a number that can be used to calculate byte address
		.align 	2
hor_line:	.ascii	"-"
		.align	2
ver_line:	.ascii	"|"
		.align 2
space:		.ascii	" "
		.align 2
turn:		.word	0			# a value of 0 indicates the user's turn, and 1 is the computer's turn
u_score:	.word	0
c_score:	.word	0
