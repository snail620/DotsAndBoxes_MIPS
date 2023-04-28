		.text
		.globl 	main
		
		# display the current board
main:		la	$a0, new_line
		li	$v0, 4
		syscall
		li	$t0, 0			# initialize counter
		li	$t2, 11			# set end condition for looping
		lw	$s2, col_bias		# store col_bias as a saved temp in $s2
		li	$v0, 4
		
display_board:	add	$a0, $t0, $s2		# calculate row letter label and store in $a0 to print
		li	$v0, 11
		syscall				# print the row letter label
		la	$a0, space		# print a space
		li	$v0, 4
		syscall
		sll	$t1, $t0, 4		# multiply counter by 16 to find offset to add to "board"
						# offset used to calculate address of current row in board to display
		la	$a0, board($t1)		# print row in board to display
		syscall
		la	$a0, new_line
		syscall
		addi	$t0, $t0, 1		# increment counter
		blt	$t0, $t2, display_board	# loop if counter is less than 11
		
		la	$a0, board_footer1	# print footers
		syscall
		la	$a0, board_footer2
		syscall
		
		# display scores
		la	$a0, display_u_score	# display user's score
		li	$v0, 4
		syscall
		lw	$t0, u_score
		move	$a0, $t0
		li	$v0, 1
		syscall
		la	$a0, new_line
		li	$v0, 4
		syscall
		la	$a0, display_c_score	# display computer's score
		syscall
		lw	$t1, c_score
		move	$a0, $t1
		li	$v0, 1
		syscall
		la	$a0, new_line
		li	$v0, 4
		syscall
		syscall
		
		# check if the game has ended
check_end:	add	$t2, $t0, $t1
		li	$t3, 35
		bge	$t2, $t3, game_end	# branch if the sum of user and computer score is greater than or equal
						# to 35 (total number of boxes)
		
	#	li	$a0, 1000		# pause for user to see updated score and what moves were made
	#	li	$v0, 32
	#	syscall
		
		li	$v0, 4			# prepare for print string syscall
		lw	$t0, turn		
		bne	$t0, $zero, else_turn	# branch to else_turn if turn in memory is not 0
						# i.e. it is the computer's turn
		la	$a0, u_turn_msg		# display u_turn_msg
		syscall
		j	u_turn			# jump to user.asm
		
else_turn:	la	$a0, c_turn_msg		# display c_turn_msg
		syscall
		j	u_turn			# in the finished program, jump to computer's turn subroutine in other file
		
		# check for who won the game
game_end:	blt	$t0, $t1, c_win		# if user score is less than computer score, branch to c_win
		
u_win:		la	$a0, u_win_msg		# display u_win_msg
		li	$v0, 4
		syscall
		# play win sound
		li	$a2, 40			# set instrument to strings
		li	$a0, 70			# set first note (B flat)
		li	$a1, 250		# set duration of first note (250 milliseconds)
		li	$a3, 127		# set volume (max volume)
		li	$v0, 33
		syscall
		addi	$a0, $a0, 5		# set note (E flat)
		syscall
		sll	$a1, $a1, 1		# double note length for subsequent notes
		addi	$a0, $a0, 5		# set note (A flat)
		syscall
		addi	$a0, $a0,-2		# set note (G flat)
		syscall
		addi	$a0, $a0,-1		# set note (F)
		syscall
		srl	$a1, $a1, 1		# halve note length for subsequent notes
		addi	$a0, $a0,-2		# set note (E flat)
		syscall
		addi	$a0, $a0, 5		# set note (A flat)
		syscall
		addi	$a0, $a0, 2		# set note (B flat)
		syscall
		addi	$a0, $a0, -7		# set note (E flat)
		syscall
		sll	$a1, $a1, 2		# quadruple note length for final note
		syscall
		j	end			# jump to end of program
		
c_win:		la	$a0, c_win_msg		# display c_win_msg
		li	$v0, 4
		syscall
		# play lose sound
		li	$a2, 115		# set instrument to percussion
		li	$a0, 45			# set pitch
		li	$a1, 500		# set duration (500 milliseconds)
		li	$a3, 127		# set volume (max volume)
		li	$v0, 33
		syscall
		addi	$a0, $a0, -4		# lower the pitch
		syscall
		addi	$a0, $a0, -3		# lower the pitch
		syscall
		
end:		li	$v0, 10			# program ends
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
		.asciiz "+++++++++++++++"	# this string is stored in memory to ensure that box checking logic works              "
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
