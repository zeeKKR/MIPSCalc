#Zuokun Yu 
#2/23/12
#A simple calculator that only processes addition
	.globl main
	.text
main:
	li $s0, 0x2b #Load 2b (Hex) into register s0. Used to verify addition signs.
	li $s1, 10   #Loads 10 into register s1. Used for multiplication.
	li $s2, 0x20 #Loads 20 (Hex) into register s2. 20 represents whitespace
	li $s3, 0x79 #Loads 79 (Hex) into register s3. 79 represents 'y'.

start:	
	#Clear registers for reuse
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0

	#Prompts the user for an expression to evaluate
	li $v0, 4
	la $a0, prompt
	syscall
	
	#Reads in a character
	li $v0, 12
	syscall
	beq $v0, $s0, new #Compares the character to the plus sign (0x20 in Hex). If so, jump to new
	move $t0, $v0	
	addi $t0, -48 #Converts char value into corresponding int value

	#Reads in a character
	li $v0, 12
	syscall
	beq $v0, $s0, new #Compares the character to the plus sign (0x20 in Hex). If so, jump to new
	move $t1, $v0
	addi $t1, -48 #Converts char value into corresponding int value
	mult $t0, $s1 #Multiplies the value in t0 by 10. The first integer is no longer the ones digit, but the tens digit.
	mflo $t0

	#Reads in a character
	li $v0, 12
	syscall
	beq $v0, $s0, new #Compares the character to the plus sign (0x20 in Hex). If so, jump to new
	move $t2, $v0
	addi $t2, -48 #Converts char value into corresponding int value
	mult $t0, $s1 #Multiplies the value in t0 by 10. The first integer is no longer the tens digit, but the hundreds digit
	mflo $t0
	mult $t1, $s1 #Multiplies the value in t1 by 10. The second integer is no longer the ones digit, but the tens digit.
	mflo $t1
	
	#Reads in a character
	li $v0, 12
	syscall
	beq $v0, $s0, new  #Compares the character to the plus sign (0x20 in Hex). If so, jump to new
	move $t3, $v0
	addi $t3, -48 #Converts char value into corresponding int value
	mult $t0, $s1 #Multiplies the value in t0 by 10. The first integer is no longer the hundreds digit, but the thousands digit
	mflo $t0
	mult $t1, $s1 #Multiplies the value in t1 by 10. The second integer is no longer the tens digit, but the hundreds digit.
	mflo $t1
	mult $t2, $s1 #Multiplies the value in t2 by 10. The third integer is no longer the ones digit, but the tens digit.
	mflo $t2

	#Reads in a character
	li $v0, 12
	syscall
	beq $v0, $s0, new #Compares the character to the plus sign (0x20 in Hex). If so, jump to new
	move $t4, $v0
	addi $t4, -48 #Converts char value into corresponding int value
	mult $t0, $s1 #Multiplies the value in t0 by 10. The first integer is no longer the thousands digit, but the ten thousands digit
	mflo $t0
	mult $t1, $s1 #Multiplies the value in t1 by 10. The second integer is no longer the hundreds digit, but the thousands digit.
	mflo $t1
	mult $t2, $s1 #Multiplies the value in t2 by 10. The third integer is no longer the tens digit, but the hundreds digit.
	mflo $t2
	mult $t3, $s1 #Multiplies the value in t3 by 10. The fourth integer is no longer the ones digit, but the tens digit.
	mflo $t3

#New works in the exact same way as above. A character is read in and compared to white space. If it is white space, the algorithm jumps to add which sums 
#all the registers. If not, it continues read in characters and multiplying previous characters by 10.
new:
	li $v0, 12
	syscall
	beq $v0, $s2, addition
	move $t5, $v0
	addi $t5, -48

	li $v0, 12
	syscall
	beq $v0, $s2, addition
	move $t6, $v0
	addi $t6, -48
	mult $t5, $s1
	mflo $t5

	li $v0, 12
	syscall
	beq $v0, $s2, addition
	move $t7, $v0
	addi $t7, -48
	mult $t5, $s1
	mflo $t5
	mult $t6, $s1
	mflo $t6
	
	li $v0, 12
	syscall
	beq $v0, $s2, addition
	move $t8, $v0
	addi $t8, -48
	mult $t5, $s1
	mflo $t5
	mult $t6, $s1
	mflo $t6
	mult $t7, $s1
	mflo $t7

	li $v0, 12
	syscall
	beq $v0, $s2, addition
	move $t9, $v0
	addi $t9, -48
	mult $t5, $s1
	mflo $t5
	mult $t6, $s1
	mflo $t6
	mult $t7, $s1
	mflo $t7
	mult $t8, $s1
	mflo $t8

addition:
	#Add the values in all the registers
	add $t0, $t0, $t1
	add $t0, $t0, $t2
	add $t0, $t0, $t3
	add $t0, $t0, $t4

	add $t0, $t0, $t5
	add $t0, $t0, $t6
	add $t0, $t0, $t7
	add $t0, $t0, $t8
	add $t0, $t0, $t9
	
	#Prints a message
	li $v0, 4
	la $a0, sum
	syscall

	#Prints the sum
	li $v0, 1
	move $a0, $t0
	syscall

	#Asks if the user wants to continue
	li $v0 4
	la $a0, cont
	syscall
	
	#Enter y to continue or anything else to quit
	li $v0, 12
	syscall
	beq $v0, $s3, start
	
	#Exit call
	li $v0, 10
	syscall

	.data
prompt:	.asciiz "\n\nPlease enter an addition expression: "
sum:	.asciiz "\nThe sum of the two integers is "
cont:	.asciiz "\nDo you want to continue adding numbers? Enter y to continue or anything else to quit\n"
