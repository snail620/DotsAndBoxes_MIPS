		.text
		.globl main
main:		li	$t0, 0			# display the current board
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
					
		la	$a0, display_u_score	# display scores
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
		
		li	$a0, 1000		# pause for user to see updated score and what moves were made
						# consider changing this to only run before computer's turn
		li	$v0, 32
		syscall
		
		lw	$t0, turn		# determine whose turn it is and jump accordingly
		bne	$t0, $zero, else_turn
		j	u_turn
else_turn:	j	end			# in the real program, jump to computer's turn subroutine in other file
		
game_end:	beq	$t0, $t1, tie		# check for who won the game/tie
		blt	$t0, $t1, c_win
		
u_win:		la	$a0, u_win_msg
		li	$v0, 4
		syscall
		j	end
		
c_win:		la	$a0, c_win_msg
		li	$v0, 4
		syscall
		j	end
		
tie:		la	$a0, tie_msg
		li	$v0, 4
		syscall

end:		li	$v0, 10
		syscall

		.data
		.globl	board
		.globl	turn
		.globl	u_score
		.globl	c_score
board:		.asciiz	"+ + + + + + + +"
		.asciiz "               "
		.asciiz	"+ + + + + + + +"
		.asciiz "               "
		.asciiz	"+ + + + + + + +"
		.asciiz "               "
		.asciiz	"+ + + + + + + +"
		.asciiz "               "
		.asciiz	"+ + + + + + + +"
		.asciiz "               "
		.asciiz	"+ + + + + + + +"
board_footer1:	.asciiz "  012345678911111\n"
board_footer2:	.asciiz	"            01234\n\n"
display_u_score:.asciiz "Your score: "
display_c_score:.asciiz "Computer's score: "
u_win_msg:	.asciiz "You won the game! Congratulations!\n"
c_win_msg:	.asciiz "The computer won the game! Better luck next time!\n"
tie_msg:	.asciiz "The game was a draw!\n"
space:		.asciiz " "
new_line:	.asciiz "\n"
		.align	2
col_bias:	.ascii	"A"
		.align 	2
turn:		.word	0			#a value of 0 indicates the user's turn, and 1 is the computer's turn
u_score:	.word	0
c_score:	.word	0
