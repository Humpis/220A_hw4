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
	li $t4, 0				# offset counter
	
linear_search_loop:
	beq $t0, $a1, linear_search_error	# end reached
	add $t1, $a0, $t4			# base + counter
	lb $t1, ($t1)				# contents of byte
	li $t2, 0				# counter 2
	
	linear_search_loop2:
	beq $t0, $a1, linear_search_error	# end reached
	bne $t2, 8, linear_search2_cont		# end of byte reached
		addi $t4, $t4, 1		# counter++
		j linear_search_loop			
	
	linear_search2_cont:
	li $t3, 1				# for masking, to be shifted
	sllv $t3, $t3, $t2			# shift mask by counter2 bits left
	and $t3, $t3, $t1			# mask and contents of byte
	srlv $t3, $t3, $t2			# shift important bit right by counter 2 bits
	beqz $t3, linear_search_done		# bit is 0
	addi $t2, $t2, 1			# counter2++
	addi $t0, $t0, 1			# counter++
	j linear_search_loop2	
	
linear_search_error:
	li $v0, -1
	jr $ra

linear_search_done:
	#li $t1, 8				# for mult
	#mul $t0, $t0, $t1			# result =  counter * 8
	#add $v0, $t0, $t2			# result = result + counter 2
	move $v0, $t0				# result
   	jr $ra

set_flag:
	bltz $a1, set_flag_error		# index < 0
	bge $a1, $a3, set_flag_error		# index >= max size
	andi $a2, $a2, 1			# least significant bit of setValue
	li $t0, 8				# for division
	div $a1, $t0 				# index / 8
	mflo $t0				# quotient
	mfhi $t1 				# remainder
	add $a0, $a0, $t0			# byte we need
	lb $t0, ($a0)				# contents of byte
	li $t2, 1				# mask
	sllv $t2, $t2, $t1			# mask shifted to bit we need
	and $t2, $t0, $t2			# byte masked 
	srlv $t2, $t2, $t1			# shifted back 
	beq $t2, $a2, set_flag_done		# important bit already equals setValue
	beqz $a2, set_flag_remove		# flag is 1 but needs to be 0, else flag is 0 and needs to be 1
	li $t2, 1				# bit to add
	sllv $t2, $t2, $t1			# shifted to where it needs to be
	add $t0, $t0, $t2			# contents + bit to add
	sb $t0, ($a0)				# store back
	j set_flag_done
	
set_flag_remove:  
	li $t2, 1				# bit to subtract
	sllv $t2, $t2, $t1			# shifted to where it needs to be
	sub $t0, $t0, $t2			# contents - bit to add
	sb $t0, ($a0)				# store back
	j set_flag_done
	
set_flag_error:
	li $v0, 0
	jr $ra
	
set_flag_done:
	li $v0, 1
	jr $ra

find_position:
	addi $sp ,$sp, -4				# save
	sw $ra, 0($sp)
	andi $a2, $a2, 65535				# convert 32 bit to 16 bit
	li $t0, 4					# for mult
	mul $t0, $t0, $a1				# currindex * 4
	add $t0, $t0, $a0				# nodes[] + currIndex
	lw $t0 ($t0)					# contents of the node at currIndex
	andi $t1, $t0, 65535				# value of node
	bge $a2, $t1, find_position_right		# if (newValue < nodes[currIndex].value ) {
		li $t1, 0xff000000				# mask for left node
		and $t1, $t0, $t1				# left node
		srl $t1, $t1, 24				# shift right
		bne $t1, 255, find_position_left_recurse	# if (leftIndex == 255) {
			move $v0, $a1					# currIndex
			li $v1, 0					# 0
			j find_position_done				# return
		find_position_left_recurse:			# } else {
			move $a1, $t1					# left index
			jal find_position
			j find_position_done
	find_position_right:				# } else {
		li $t1, 0x00ff0000				# mask for right node
		and $t1, $t0, $t1				# right node
		srl $t1, $t1, 16				# shift right
		bne $t1, 255, find_position_right_recurse	# if (rightIndex == 255) {
			move $v0, $a1					# currIndex
			li $v1, 1					# 1
			j find_position_done				# return
		find_position_right_recurse:			# } else {
			move $a1, $t1					# right index
			jal find_position
find_position_done:
	lw $ra, 0($sp)					# load
	addi $sp ,$sp, 4
    	jr $ra

add_node:
	lw $t0, 0($sp)					# max size
	lw $t1, 4($sp)					# flag[]
	addi $sp, $sp, 8
	
    	addi $sp, $sp, -28				# save stack
    	sw $s0, 0($sp)
    	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
    	sw $s5, 20($sp)
    	sw $ra, 24($sp)
    	
    	move $s0, $a0					# Node[] nodes
    	move $s1, $a1					# int rootIndex
    	move $s2, $a2					# int newValue
    	move $s3, $a3					# int newIndex
   	move $s4, $t1					# byte[] flags
    	move $s5, $t0					# int maxSize
    	
    	andi $s1, $s1, 255				# rootIndex = toUnsignedByte(rootIndex);
    	andi $s3, $s3, 255				# newIndex = toUnsignedByte(newIndex);
    	
    	bge $s1, $s5, add_node_error			# if (rootIndex >= maxSize
    	bge $s3, $s5, add_node_error			# || newIndex >= maxSize) return 0;
    	
    	andi $s2, $s2, 65535				# newValue = toSignedHalfWord(newValue);
    	
    	# // Determine if a root node actually exists at rootIndex
	li $t0, 8					# for divide
	div $s1, $t0					# root index / 8
	mflo $t0					# quotient
	mfhi $t1					# remainder
	add $t0, $t0, $s4				# base + byte offset
	lb $t0, ($t0)					# contents of that
	li $t2, 1					# mask
	sllv $t2, $t2, $t1				# mask shifted
	and $t2, $t2, $t0				# bit of byte we need
	srlv $t2, $t2, $t1				# shifted back. boolean validRoot = nodeExists(rootIndex);
	
	bne $t2, 1, add_node_invalid			# if (validRoot) { // if a valid root node already exists
		#// Find a valid position in the BST with newValue as the comparison
		move $a0, $s0					# nodes
		move $a1, $s1					# rootIndex
		move $a2, $s2					# newValue
		jal find_position				# int parentIndex, leftOrRight = find_position(nodes, rootIndex,
		bnez $v0, add_node_right			# if (leftOrRight == left) {
			# // update parent’s Left Node inde
			li $t0, 4					# for mult
			mul $t0, $v0, $t0				# parnetIndex * 4	
			add $t0, $t0, $s0				# nodes[parentIndex]
			lw $t1, ($t0)					# contents of node
			li $t2, 0x00ffffff				# mask for all but left node
			and $t2, $t2, $t1				# all but left node
			sll $t1, $s3, 24				# shift newIndex to its place
			add $t2, $t2, $t1				# .left = newIndex;
			sw $t2, ($t0)					# nodes[parentIndex].left = newIndex
			j add_node_final				# }
		add_node_right:					# } else {
			# // update parent’s right Node inde
			li $t0, 4					# for mult
			mul $t0, $v0, $t0				# parnetIndex * 4	
			add $t0, $t0, $s0				# nodes[parentIndex]
			lw $t1, ($t0)					# contents of node
			li $t2, 0xff00ffff				# mask for all but right node
			and $t2, $t2, $t1				# all but right node
			sll $t1, $s3, 16				# shift newIndex to its place
			add $t2, $t2, $t1				# .right = newIndex;
			sw $t2, ($t0)					# nodes[parentIndex].right = newIndex;
			j add_node_final				# }
	add_node_invalid: #  // we must add newValue as a root node instead
		move $s3, $s1					# newIndex = rootIndex;
	add_node_final:
		li $t0, 4
    		mul $t0, $s3, $t0				# newindex * 4
    		add $t0, $s0, $t0				# nodes[new Index]
    		li $t1, 0xffff0000				# left and right are 255
    		add $t1, $t1, $s2				# leaf node with new value
    		sw $t1, ($t0)
    		
    		move $a0, $s4					# flags
    		move $a1, $s3					# newIndex,
    		li $a2, 1					# 1
    		move $a3, $s5					# max size
    		jal set_flag
    		j add_node_done
    		
add_node_error:
    	lw $s0, 0($sp)					# load stack
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s5, 20($sp)
    	lw $ra, 24($sp)
    	addi $sp, $sp, 28
    	li $v0, 0
	jr $ra
	
add_node_done:   	
    	lw $s0, 0($sp)					# load stack
    	lw $s1, 4($sp)
    	lw $s2, 8($sp)
    	lw $s3, 12($sp)
    	lw $s4, 16($sp)
    	lw $s5, 20($sp)
    	lw $ra, 24($sp)
    	addi $sp, $sp, 28
    	#li $v0, 1					# should be from set flags 
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

