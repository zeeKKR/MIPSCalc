#Zuokun Yu
#3/15
#A more complex calculator that can handle expressions that include multiple operators
#t0- Pointer used to iterate through the expression
#t2- Length of each operand
#t5- Answer in integer form
#t6- points to top of operandstack
#t7- points to top of operatorstack
	.text
	.globl main
main:
	li $k0, 0x79 #ASCII for 'y' character. Used to confirm user choice in prompts

	li $s0, 0x20 #ASCII for whitespace
	li $s1, 0x2d #ASCII for a negative sign
	li $s2, 10 #Used in the division algorithm
	li $s3, 0x2a #ASCII for Multiplication
	li $s4, 0x2b #ASCII for Addition
	li $s5, 0x2f #ASCII for Division
	li $s6, 0x21 #ASCII for exclamation mark. Denotes the bottom of the stack

	#Prompts user for name
	li $v0, 4
	la $a0, namePrompt
	syscall

	#Reads in user response
	li $v0, 8
	la $a0, name
	li $a1, 16
	syscall

	#Prints 'Hi'
	li $v0, 11
	li $a0, 0x48
	syscall

	li $v0, 11
	li $a0, 0x69
	syscall

	#Prints a whitespace
	li $v0, 11
	li $a0, 0x20 #Whitespace
	syscall	

	#Prints the inputted name. Printing is done character by character to prevent line breaks between Hi and name
	la $t0, name
nameLoop:
	lb $t1, ($t0)
	beq $t1, $zero, expressionPrompt
	li $v0, 11
	move $a0, $t1
	syscall
	addi $t0, 1
	j nameLoop

	#Prompts user for mathematical expression
expressionPrompt:
	li $v0, 4
	la $a0, expPrompt
	syscall	

	#Reads in the expression
	li $v0, 8
	la $a0, exp
	li $a1, 32
	syscall

	#Loads registers with addresses of 1) user inputted expression 2)operand stack pointer 3)operator stack pointer
	la $t0, exp
	la $t6, operandStack
	la $t7, operatorStack

	#Gets total number of operators
	jal getNumberOfOperators

	#Initializes operand and operator stack with a '!' to denote the bottom
	jal initializeOperandStack
	jal initializeOperatorStack

	#Gets the length of a single part of an expression.
	jal getSingleLength

	#Converts the inputted character "value" into the equivalent integer value
	jal getIntValue

	#Pushes the operand onto a stack
	jal pushOperandStack

keyLoop:
	#Clearing register t2 (length of a single operator for loop purposes)
	move $t2, $zero

	la $t1, answer
	li $k1, 8
clear:
	#Clear answer to avoid character carry over
	sb $zero, ($t1)
	addi $t1, 1
	addi $k1, -1
	bgtz $k1, clear

	#Pushes the operator onto the stack while considering precedence
	jal pushOperatorStack

	#Gets the next part of the expression and pushes it onto the stack
	jal getSingleLength

	jal getIntValue

	jal pushOperandStack

	#Register s7 is the number of operations that the expression contains which is equivalent to the number
	#of times the loop should run
	addi $s7, -1
	beq $s7, $zero, isEmptyStack
	j keyLoop

	#Once all the operands are pushes, the operator stack must be emptied
isEmptyStack:
	jal clearStack

	addi $t7, 1

	#The final value of the expression resides on the top of the operand stack
	addi $t6, -4
	lw $t5, ($t6)	

	#Initalizes final stack with a '!' to denote the bottom
	jal initializeFinalStack

	#Converts the integer value into one or several characters so it may be printed as a string
	jal divAlg

	#Prints answer
	li $v0, 4
	la $a0, answer
	syscall

	#Prints a line break	
	li $v0, 4
	la $a0, linebreak
	syscall
		
	#Prints the user inputted name
	li $v0, 4
	la $a0, name
	syscall

	#Asks if the user wants to input another expression
	li $v0, 4
	la $a0, contPrompt
	syscall

	#'y' continues the calculator. Anything else leads to the exit call
	li $v0, 12
	syscall
	beq $v0, $k0, cont

	#Final exit call
	li $v0, 10
	syscall

cont:
	#Asks the user input an operator and operand
	li $v0, 4
	la $a0, contMessage
	syscall

	#Reads in user input
	li $v0, 8
	la $a0, readCont
	la $a1, 16
	syscall

	#Loads address of string that contains user input. Adjusts registers so that it works properly with keyLoop
	la $t0, readCont
	addi $t0, 2
	addi $t6, 4
	li $s7, 1
	j keyLoop

	#An operator always occurs in the form 'whitespace''operator''whitespace'. Subroutine looks for that specific 	#sequence
getNumberOfOperators:
	lb $t1, ($t0)
	beq $t1, $s0, gNOF1
	beq $t1, $zero, getNumberOfOperatorsExit
	addi $t0, 1
	j getNumberOfOperators

getNumberOfOperatorsExit:
	la $t0, exp
	jr $ra

gNOF1:
	addi $t0, 1
	lb $t1, ($t0)
	beq $t1, $s1, gNOF2
	beq $t1, $s3, gNOF2
	beq $t1, $s4, gNOF2
	beq $t1, $s5, gNOF2
	addi $t0, 1
	j getNumberOfOperators

gNOF2:
	addi $t0, 1
	lb $t1, ($t0)
	beq $t1, $s0, gNOF3Increment
	addi $t0, 1
	j getNumberOfOperators

gNOF3Increment:
	addi $s7, 1
	addi $t0, 1
	j getNumberOfOperators

	#Operand stack contains words which take up 4 bytes. Thus, pushing 4 characters for addressing purposes
initializeOperandStack:
	li $t1, 0x21
	sb $t1, ($t6)
	addi $t6, 1
	li $t1, 0x21
	sb $t1, ($t6)
	addi $t6, 1
	li $t1, 0x21
	sb $t1, ($t6)
	addi $t6, 1
	li $t1, 0x21
	sb $t1, ($t6)
	addi $t6, 1
	jr $ra

	#An operator stack only contains characters. Thus, only 1 exclamation mark needs to be pushed
initializeOperatorStack:
	li $t1, 0x21
	sb $t1, ($t7)
	addi $t7, 1
	jr $ra

	#Gets the length of one segment of the total expression. Counts the number of characters before encountering 	#whitespace
getSingleLength:
	lb $t1, ($t0)
	beq $t1, $s1, negLength
	beq $t1, $s0, getSingleLengthExit
	addi $t0, 1
	addi $t2, 1
	j getSingleLength

	#Skips negative signs in calculating length
negLength:
	addi $t0, 1
	j getSingleLength
	
	#Advances t0 such that it points to the next operand
getSingleLengthExit:
	addi $t0, 3
	jr $ra

	#Converts operand to an integer. Multiplication by powers of 10 are required for the various places
getIntValue:
	move $t4, $zero
	move $t1, $t0
	addi $t1, -4
	lb $t3, ($t1)
	addi $t4, 1
	addi $t3, -48
	move $t5, $t3
	beq $t4, $t2, isNegCheck
	addi $t1, -1
	lb $t3, ($t1)
	addi $t4, 1
	addi $t3, -48
	mult $t3, $s2
	mflo $t3
	add $t5, $t5, $t3
	beq $t4, $t2, isNegCheck
	addi $t1, -1
	lb $t3, ($t1)
	addi $t4, 1
	addi $t3, -48
	mult $t3, $s2
	mflo $t3
	mult $t3, $s2
	mflo $t3
	add $t5, $t5, $t3
	beq $t4, $t2, isNegCheck
	addi $t1, -1
	lb $t3, ($t1)
	addi $t4, 1
	addi $t3, -48
	mult $t3, $s2
	mflo $t3
	mult $t3, $s2
	mflo $t3
	mult $t3, $s2
	mflo $t3
	add $t5, $t5, $t3
	beq $t4, $t2, isNegCheck
	addi $t1, -1
	lb $t3, ($t1)
	addi $t4, 1
	addi $t3, -48
	mult $t3, $s2
	mflo $t3
	mult $t3, $s2
	mflo $t3
	mult $t3, $s2
	mflo $t3
	mult $t3, $s2
	mflo $t3
	add $t5, $t5, $t3
	beq $t4, $t2, isNegCheck

	#Checks if the integer is negative
isNegCheck:
	addi $t1, -1
	lb $t3, ($t1)
	beq $t3, $s1, negInt
	jr $ra
	
	#Handling negative integers
negInt:
	addi $t5, -1
	not $t5, $t5
	jr $ra

	#Pushing operands
pushOperandStack:
	sw $t5, ($t6)
	addi $t6, 4
	jr $ra

	#Checks whether or not operator is pushed or additional action is required before pushing
pushOperatorStack:
	move $t1, $t0
	addi $t1, -2
	lb $t3, ($t1)
	beq $t3, $s1, lowPrecedence
	beq $t3, $s4, lowPrecedence
	beq $t3, $s3, highPrecedence
	beq $t3, $s5, highPrecedence

	#Addition/subtraction sign is to be pushed. Checks whether the operator stack is empty or not. If not, pop the top 		#of operator stack, evaluate using the top two integers of the operand stack, repush the calculated value, and 			#then push the operator
lowPrecedence:
	addi $t7, -1
	lb $t8, ($t7)
	addi $t7, 1
	beq $t8, $s6, emptyStack
	beq $t8, $s4, addition
	beq $t8, $s1, subtraction
	beq $t8, $s3, multiplication
	beq $t8, $s5, division
	
	#Multiplication/divsion sign is to be pushed. Checks if the top of the operator stack to see if its addition, 			#subtraction or if its empty. In that case, push the operator. Otherwise, pop the top of the operator stack, 			#evaluate using the top two integers of the operand stack, repush the calculated value, and then push the operator
highPrecedence:
	addi $t7, -1
	lb $t8, ($t7)
	addi $t7, 1
	beq $t8, $s6, emptyStack
	beq $t8, $s4, emptyStack
	beq $t8, $s1, emptyStack
	beq $t8, $s3, multiplication
	beq $t8, $s5, division
	
	#If stack is empty, simply push
emptyStack:
	sb $t3, ($t7)
	addi $t7, 1
	jr $ra	
	
addition:
	addi $t7, -1
	sb $t3, ($t7)
	addi $t7, 1
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)
	add $t8, $t8, $t9
	sw $t8, ($t6)
	addi $t6, 4
	jr $ra

subtraction:
	addi $t7, -1
	sb $t3, ($t7)
	addi $t7, 1
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)
	sub $t8, $t9, $t8
	sw $t8, ($t6)
	addi $t6, 4
	jr $ra

multiplication:
	addi $t7, -1
	sb $t3, ($t7)
	addi $t7, 1
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)
	mult $t8, $t9
	mflo $t8
	sw $t8, ($t6)
	addi $t6, 4
	jr $ra

division:
	addi $t7, -1
	sb $t3, ($t7)
	addi $t7, 1
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)
	div $t9, $t8
	mflo $t8
	sw $t8, ($t6)
	addi $t6, 4
	jr $ra

	#After all operands are pushed, the operator stack must be emptied
clearStack:
	addi $t7, -1
	lb $t1, ($t7)
	beq $t1, $s1, subPush
	beq $t1, $s3, multPush
	beq $t1, $s4, addPush
	beq $t1, $s5, divPush
	jr $ra

subPush:
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)	
	sub $t8, $t9, $t8	
	sw $t8, ($t6)
	addi $t6, 4
	j clearStack	

multPush:
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)	
	mult $t9, $t8	
	mflo $t8
	sw $t8, ($t6)
	addi $t6, 4
	j clearStack	
addPush:
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)	
	add $t8, $t9, $t8	
	sw $t8, ($t6)
	addi $t6, 4
	j clearStack

divPush:
	addi $t6, -4
	lw $t8, ($t6)
	addi $t6, -4
	lw $t9, ($t6)	
	div $t9, $t8	
	mflo $t8
	sw $t8, ($t6)
	addi $t6, 4
	j clearStack	

	#Initializes final stack with a '!' to denote the bottom
initializeFinalStack:
	la $s8, finalStack
	sb $s6, ($s8)
	addi $s8, 1
	jr $ra

	#Divide by 10 until quotient is 0. Each time one digit of the final output is returned. The order is reversed so a 	#stack is used to obtain the proper ordering. Negatives are handled here.
divAlg:
	blt $t5, $zero, divAlgNeg
	div $t5, $s2
	mfhi $t1
	addi $t1, 48
	sb $t1, ($s8)
	addi $s8, 1
	mflo $t5
	beq $t5, $zero, divAlgReverse	
	j divAlg

	#Multiply negative integers by -1 to obtain the positive value. The division algorithm is applied normally and the 	#negative sign is added later
divAlgNeg:
	li $t1, -1
	mult $t5, $t1
	mflo $t5
	
	#Identical to the division algorith for positive integers, but branches differently to add the negative sign
divAlgNegLoop:
	div $t5, $s2
	mfhi $t1
	addi $t1, 48
	sb $t1, ($s8)
	addi $s8, 1
	mflo $t5
	beq $t5, $zero, divAlgReverseNeg	
	j divAlgNegLoop

	#Loads location of answer string	 
divAlgReverse:
	la $t1, answer
	j divAlgLoop

	#Loads location of answer string
divAlgReverseNeg:
	la $t1, answer
	j divAlgLoopNeg2

	#Uses a stack to properly output the answer in a string format
divAlgLoop:
	addi $s8, -1
	lb $t3, ($s8)
	beq $t3, $s6, divAlgReverseExit
	sb $t3, ($t1)
	addi $t1, 1
	j divAlgLoop

	#Adds a negative sign. Otherwise, the same as divAlgLoop
divAlgLoopNeg2:
	sb $s1, ($t1)
	addi $t1, 1
divAlgLoopNeg3:
	addi $s8, -1
	lb $t3, ($s8)
	beq $t3, $s6, divAlgReverseExit
	sb $t3, ($t1)
	addi $t1, 1
	j divAlgLoopNeg3

divAlgReverseExit:
	jr $ra


	.data
operandStack: .space 128
operatorStack: .space 8
finalStack: .space 8
answer: .space 8
name: .space 16
exp: .space 32
namePrompt: .asciiz "Please enter your name: "
expPrompt: .asciiz "Please enter an expression: "
contPrompt: .asciiz "Would you like to continue? "
contMessage: .asciiz "\nPlease enter an operation and an operand: "
readCont: .space 16
linebreak: .asciiz "\n"