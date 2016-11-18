##############################################################
# Homework #4
# name: Vidar Minkovsky
# sbuid: 109756598
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

preorder:
	addi $sp, $sp, -16			# stack
	sw $s0, 0($sp)				# store s on the stack
	sw $s1, 4($sp)				# store s on the stack
	sw $s2, 8($sp)	
	sw $ra, 12($sp)
	move $s0, $a0				# store a regs
	move $s1, $a1	
	move $s2, $a2		
	lw $s0, ($s0)		
	
	li $t0, 0x0000ffff			# last 16 bits
	and $t0, $s0, $t0			# int nodeValue = currNodeAddr.value; // Get the 16-bit integer value
		
itof:	
	li $t3, 0				# number of nums converted
	li $t1, 10				# for dividing	
convert_loop:	
	div $t0, $t1				# number/10
	mfhi $t2				# remainder
	mflo $t0 				# quotient
	addi $t2, $t2, 48			# remainder + '0'
	addi $sp, $sp, -1			# stack
	sb $t2, 0($sp)				# store letter on the stack
	addi $t3, $t3, 1			# num nums coverted++
	beqz $t0, store_loop
	j convert_loop	
store_loop:
	beqz $t3, itof_done			# all chars stored
	move $a0, $s2				# file descriptor
	move $a1, $sp				# adress of char buffer
	li $a2, 1				# num chars to write
	li $v0, 15				# syscall
	syscall
	addi $sp, $sp, 1			# reset stack up
	addi $t3, $t3, -1			# numb to store--
	j store_loop
itof_done:					# write(fd, "\n", 1); // Write a newline to file
	move $a0, $s2				# file desc
	la $a1, newLine				# buffer
	li $a2, 1				# numb of chars to write
	li $v0, 15				# syscall
	syscall
	
	li $t0, 0				# int nodeIndex;
	li $t0, 0xff000000			# first 8 bits
	and $t0, $s0, $t0			# nodeIndex = currNodeAddr.left; // Fetch the 8-bit index Left Node
	srl $t0, $t0, 24			# bring it back now yall
	# check for left node
	beq $t0, 255, checkRightNode		# if (nodeIndex != 255) {
		# Determine the address of the left child in node array
		sll $t0, $t0, 2				# offset = nodeIndex * 4
		add $a0, $t0, $s1			# int leftNodeAddr = nodes + leftOffset;
		move $a1, $s1				# nodes[]
		move $a2, $s2				# fd
		jal preorder				# preorder(leftNodeAddr, nodes, fd);

checkRightNode:
	li $t0, 0				# int nodeIndex;
	li $t0, 0x00ff0000			# right
	and $t0, $s0, $t0			# nodeIndex = currNodeAddr.right; // Fetch the 8-bit index Left Node
	srl $t0, $t0, 16			# bring it back now yall
	# check for right node
	beq $t0, 255, preorder_done		# if (nodeIndex != 255) {
		# Determine the address of the left child in node array
		sll $t0, $t0, 2				# offset = nodeIndex * 4
		add $a0, $t0, $s1			# int leftNodeAddr = nodes + leftOffset;
		move $a1, $s1				# nodes[]
		move $a2, $s2				# fd
		jal preorder				# preorder(leftNodeAddr, nodes, fd);
	
preorder_done:
	lw $s0, 0($sp)			# store s on the stack
	lw $s1, 4($sp)			# store s on the stack
	lw $s2, 8($sp)			# store s on the stack
	lw $ra, 12($sp)
	addi $sp, $sp, 16		# stack
	jr $ra

    	
##############################
# PART 2 FUNCTIONS
##############################

linear_search:
	li $t0, 0				# counter
	
linear_search_loop:
	beq $t0, $a1, linear_search_error	# end reached
	add $t1, $a0, $t0			# base + counter
	lb $t1, ($t1)				# contents of byte
	li $t2, 0				# counter 2
	
	linear_search_loop2:
	beq $t0, $a1, linear_search_error	# end reached
	bne $t2, 8, linear_search2_cont		# end of byte reached
		addi $t0, $t0, 1		# counter++
		j linear_search_loop			
	
	linear_search2_cont:
	li $t3, 1				# for masking, to be shifted
	sllv $t3, $t3, $t2			# shift mask by counter2 bits left
	and $t3, $t3, $t1			# mask and contents of byte
	srlv $t3, $t3, $t2			# shift important bit right by counter 2 bits
	beqz $t3, linear_search_done		# bit is 0
	addi $t2, $t2, 1			# counter2++
	j linear_search_loop2	
	
linear_search_error:
	li $v0, -1
	jr $ra

linear_search_done:
	li $t1, 8				# for mult
	mul $t0, $t0, $t1			# result =  counter * 8
	add $v0, $t0, $t2			# result = result + counter 2
   	jr $ra

set_flag:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -20
    ###########################################
    jr $ra

find_position:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -30
    li $v1, -40
    ###########################################
    jr $ra

add_node:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -50
    ###########################################
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

get_parent:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -60
    li $v1, -70
    ###########################################
    jr $ra

find_min:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -80
    li $v1, -90
    ###########################################
    jr $ra

delete_node:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -100
    ###########################################
    jr $ra

##############################
# EXTRA CREDIT FUNCTION
##############################

add_random_nodes:
    #Define your code here
    jr $ra



#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

newLine: .word '\n'

#place any additional data declarations here

