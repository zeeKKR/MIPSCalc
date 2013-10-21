#Zuokun Yu
#3/1/12
#4 function calculator with negative integer support	
	.globl main
	.text
main:
	#Variable Dictionary
	#$t0 holds the hexadecimal representation of various operations eg: Addition, Subtraction, Multiplication, Division
	#$t1 holds the hexadecimal representation of whitespace

	#$t2 holds the length of the first integer
	#$t3 holds the length of the second integer
	#$t4 temporarily used to store characters during the subroutine signAndInitialLength

	#$t5 holds the sign of the first integer
	#$t6 holds the value of the second integer
	#$t7 temporarily used to store characters while calculating the second integer

	#$t9 holds the final answer
	
	#$s0 is a pointer to the string
	#$s1 holds the value of the first integer
	#$s2 temporarily used to store characters while calculating the first integer
	#$s4 holds the remainder for division
	#$s5 a pointer to the first character of the string	
	#$s6 permamently holds the length of the first integer
	#$s7 holds the sign of the expression eg: Addition, Subtraction, Multiplication, Division	

	li $t1, 0x20 #whitespace
	li $t8, 10   #Used to numbers in tens, hundreds etc place in base 10
	li $s3, 0x79 #Represents the letter y

	li $t5, 0 #0 if the first integer is positive. 1 otherwise.
	li $s8, 0 #0 if the second integer is positive. 1 otherwise.
repeat:
	#Clear registers
	move $t2, $zero
	move $t3, $zero
	move $t4, $zero
	move $t5, $zero
	move $s7, $zero
	move $s8, $zero
	move $s0, $zero
	move $s1, $zero
	move $s2, $zero
	move $t6, $zero
	move $t7, $zero
	move $t9, $zero
	move $s4, $zero

	#Prompts user for expression
	li $v0, 4
	la $a0, prompt
	syscall

	#Reads in a string
	li $v0, 8
	la $a0, inputS
	li $a1, 16
	syscall
	move $s0, $a0
	move $s5, $a0

	j signAndInitialLength

firstInt:
	move $s6, $t2
	move $s0, $s5 #$s5 is a pointer to the first character of the string
	add $s0, $s0, $t2 #Adding the length of the first integer yields the last digit
			  #of that integer
	lb $s1, ($s0)
	beq $t2, $zero, secondInt #If $t2(length of first integer), then there are no
				  #more digits to process. If so, process the second integer
	addi $s0, -1	#Iterates through the integer digit by digit backwards
	addi $t2, -1	
	addi $s1, -48 	#Change to int
	
	#The overall logic for the next four blocks of code are nearly identical.
	lb $s2, ($s0)
	beq $t2, $zero, secondInt
	addi $s2, -48
	mult $s2, $t8	#Multiply the second digit by 10 since it occupies the
			#tens digit
	mflo $s2
	add $s1, $s1, $s2 #Add that value into $s1
	addi $s0, -1
	addi $t2, -1
	

	lb $s2, ($s0)
	beq $t2, $zero, secondInt
	addi $s2, -48
	mult $s2, $t8
	mflo $s2
	mult $s2, $t8 #Multiply the third digit by 100 since it occupies the
		      #hundreds digit
	mflo $s2
	add $s1, $s1, $s2
	addi $s0, -1
	addi $t2, -1
	
	
	lb $s2, ($s0)
	beq $t2, $zero, secondInt
	addi $s2, -48
	mult $s2, $t8
	mflo $s2
	mult $s2, $t8
	mflo $s2
	mult $s2, $t8  #Multiply the fourth digit by 1000 since it occupies the
		       #thousands digit
	mflo $s2
	add $s1, $s1, $s2
	addi $s0, -1
	addi $t2, -1
	

	lb $s2, ($s0)
	beq $t2, $zero, secondInt
	addi $s2, -48
	mult $s2, $t8
	mflo $s2
	mult $s2, $t8
	mflo $s2
	mult $s2, $t8
	mflo $s2
	mult $s2, $t8  #Multiply the fifth digit by 10000 since it occupies the
		       #ten thousands digit
	mflo $s2
	add $s1, $s1, $s2	

	#The logic behind the subroutine secondInt is IDENTICAL to firstInt.
secondInt:
	move $s0, $s5
	add $s0, $s0, $s6
	add $s0, $s0, $t3
	add $s0, $s0, 2

	lb $t6, ($s0)		
	addi $s0, -1
	addi $t3, -1
	addi $t6, -48
	beq $t3, $zero, process #If there are no more digits to
				#the second character, process all the digits

	lb $t7, ($s0)
	addi $t7, -48
	mult $t7, $t8
	mflo $t7
	add $t6, $t6, $t7
	addi $s0, -1
	addi $t3, -1
	beq $t3, $zero, process

	lb $t7, ($s0)
	addi $t7, -48
	mult $t7, $t8
	mflo $t7
	mult $t7, $t8
	mflo $t7
	add $t6, $t6, $t7
	addi $s0, -1
	addi $t3, -1
	beq $t3, $zero, process

	lb $t7, ($s0)
	addi $t7, -48
	mult $t7, $t8
	mflo $t7
	mult $t7, $t8
	mflo $t7
	mult $t7, $t8
	mflo $t7
	add $t6, $t6, $t7
	addi $s0, -1
	addi $t3, -1
	beq $t3, $zero, process

	lb $t7, ($s0)
	addi $t7, -48
	mult $t7, $t8
	mflo $t7
	mult $t7, $t8
	mflo $t7
	mult $t7, $t8
	mflo $t7
	mult $t7, $t8
	mflo $t7
	add $t6, $t6, $t7
	addi $s0, -1
	addi $t3, -1
	beq $t3, $zero, process

printDiv:
	#Prints a message regarding the quotient
	li $v0, 4
	la $a0, outputDiv
	syscall

	#Prints the quotient
	li $v0, 1
	move $a0, $t9
	syscall

	#Prints a message regarding the remainder
	li $v0, 4
	la $a0, outputDiv2
	syscall

	#Prints the remainder
	li $v0, 1
	move $a0, $s4
	syscall

	j continue
print:

	#Prints a message
	li $v0, 4
	la $a0, output
	syscall

	#Prints the value of the expression
	li $v0, 1
	move $a0, $t9
	syscall
	
continue:
	#Asks if the user wants to continue
	li $v0 4
	la $a0, cont
	syscall
	
	#Enter y to continue or anything else to quit
	li $v0, 12
	syscall
	beq $v0, $s3, repeat
	
	#Exit call
	li $v0, 10
	syscall

signAndInitialLength:
	#Determines inputted sign and length of each 
	lb $t4, ($s0)
	li $t0, 0x2d #Subtraction sign #Checks if the first character is
				       #a negative sign.
	beq $t4, $t0, isNegFirstInt    #If so, process the negative integer
loop1Start:
	#Iterates through the string until it finds the first instance of an operator 
	#that is not the first character
	addi $s0, 1
	lb $t4, ($s0)
	li $t0, 0x2b #Addition sign
	beq $t4, $t0, finalLength
	li $t0, 0x2d #Subtraction sign
	beq $t4, $t0, finalLength
	li $t0, 0x2a #Multiplication sign
	beq $t4, $t0, finalLength
	li $t0, 0x2f #Division sign
	beq $t4, $t0, finalLength
	addi $t2, 1   		
	j loop1Start #While loop

finalLength:
	#Stores the sign of the expression in a register and calculates the length of the second integer
	move $s7, $t4 
	addi $s0, 1
	lb $t4, ($s0)
	li $t0, 0x2d #Subtraction sign
	beq $t4, $t0, isNegSecondInt
loop2Start:
	#Iterates through the second half of the string until it finds whitespace
	addi $s0, 1
	lb $t4, ($s0)
	beq $t4, $t1, firstInt
	addi $t3, 1
	j loop2Start #While loop

isNegFirstInt:
	#Register serves as a boolean
	li $t5, 1 
	j loop1Start #Return to finding the length of the first integer

isNegSecondInt:
	#Register serves as a boolean
	li $s8, 1
	j loop2Start #Return to finding the length of the second integer

process:
	bne $t5, $zero, negHandleFirst #Jumps to subroutine to convert positive
				       #integers into negative integers
	bne $s8, $zero, negHandleSecond#Jumps to subroutine to convert positive
				       #integers into negative integers
	#Go to appropriate subroutine depending on the expression's sign
	li $t0, 0x2b #Addition sign
	beq $s7, $t0, addition
	li $t0, 0x2d #Subtraction sign
	beq $s7, $t0, subtraction
	li $t0, 0x2a #Multiplication sign
	beq $s7, $t0, multiplication
	li $t0, 0x2f #Division sign
	beq $s7, $t0, division	
	
negHandleFirst:
	addi $s1, -1 #Adjust for two's complement
	not $s1, $s1 #Negate the number
	bne $s8, $zero, negHandleSecond #Check if the second integer is negative
	#Go to appropriate subroutine depending on the expression's sign
	li $t0, 0x2b #Addition sign
	beq $s7, $t0, addition
	li $t0, 0x2d #Subtraction sign
	beq $s7, $t0, subtraction
	li $t0, 0x2a #Multiplication sign
	beq $s7, $t0, multiplication
	li $t0, 0x2f #Division sign
	beq $s7, $t0, division

negHandleSecond:
	addi $t6, -1 #Adjust for two's complement
	not $t6, $t6 #Negate the number
	#Go to appropriate subroutine depending on the epxression's sign
	li $t0, 0x2b #Addition sign
	beq $s7, $t0, addition
	li $t0, 0x2d #Subtraction sign
	beq $s7, $t0, subtraction
	li $t0, 0x2a #Multiplication sign
	beq $s7, $t0, multiplication
	li $t0, 0x2f #Division sign
	beq $s7, $t0, division
	
addition:
	add $t9, $s1, $t6
	j print
	
subtraction:
	sub $t9, $s1, $t6
	j print

multiplication:
	mult $s1, $t6
	mflo $t9
	j print

division:
	div $s1, $t6
	mfhi $s4
	mflo $t9
	j printDiv

	.data
prompt:	.asciiz "\nPlease enter an expression: "
inputS:	.space 16
output: .asciiz "\nThe expression evaluates to "
outputDiv:	.asciiz "\nInteger division yields "
outputDiv2: .asciiz "\nThe remainder is "
cont: .asciiz "\nDo you want to continue evaluating expressions? Enter y to continue or anything else to quit\n"
