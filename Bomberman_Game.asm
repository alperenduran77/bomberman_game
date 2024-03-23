.data
map1: .space 4000  # 200 * 200 characters
map2: .space 40000  # 200 * 200 characters
r: .word 0 # Initializes integer 'r' for rows
c: .word 0 # Initializes integer 'c' for columns
newline: .asciiz "\n" # String for newline character
map_header: .asciiz "---MAP---\n" # String for map header

.text
.globl main
main:
    jal read  # Calls the 'read' subroutine
    jal solve   # Calls the 'solve' subroutine
    jal print # Calls the 'print' subroutine
    
read:
    # Read r and c
    li $v0, 5        # Sets $v0 for read_int syscall
    syscall          # Reads integer into $v0 (r)
    sw $v0, r        # Stores value of r
    li $v0, 5        # Sets $v0 for another read_int syscall
    syscall          # Reads integer into $v0 (c)
    sw $v0, c         # Stores value of c

    # Calculate the total number of iterations for the loops
    lw $t0, r        # Loads value of r into $t0
    lw $t1, c        # Loads value of c into $t1
    mul $t2, $t0, $t1 # Multiplies r and c, stores in $t2

    # Loop for reading map1 and initializing map2
    li $t3, 0        # Sets loop counter to 0
    la $t4, map1     # Loads address of map1 into $t4
    la $t5, map2      # Loads address of map2 into $t5

read_loop:
    bge $t3, $t2, end_read_loop # If counter >= r*c, exit loop

    # Read a character into map1
    li $v0, 12       # Sets $v0 for read_char syscall
    syscall           # Reads character into $v0
    beq $v0, 10, skip_newline  # If character is newline, skip to next iteration

    # Store the read character in map1 and initialize map2 with 'O'
    sb $v0, 0($t4)    # Stores character in map1
    li $t6, 'O'      # Loads 'O' into $t6
    sb $t6, 0($t5)    # Stores 'O' in map2

    addi $t4, $t4, 1 # Increments map1 address
    addi $t5, $t5, 1 # Increments map2 address
    addi $t3, $t3, 1 # Increments loop counter

skip_newline:
    j read_loop # Jumps back to start of loop

end_read_loop:

solve:
    # Nested Loop for Marking
    li $s0, 0         # i = 0, outer loop index
    lw $t0, r          # Loads value of r into $t0

outer_loop:
    bge $s0, $t0, end_outer_loop # if i >= r, exit outer loop

    li $s1, 0         # j = 0, inner loop index
    lw $t1, c         # Loads value of c into $t1

inner_loop:
    bge $s1, $t1, end_inner_loop # if j >= c, exit inner loop

    # Calculate index for map1[i][j]
    mul $t2, $s0, $t1 # t2 = i * c
    add $t2, $t2, $s1 # t2 = i * c + j
    la $t3, map1      # Loads address of map1 to $t3
    add $t3, $t3, $t2 # address of map1[i][j]

    lb $t4, 0($t3)    # load map1[i][j]
    li $t5, 'O'       # Loads map[i][j] with 'O'
    bne $t4, $t5, skip_marking # If map1[i][j] != 'O', skip marking

    # Marking map2 based on the condition
    la $t6, map2 #Loads address of map2 to $t6
    add $t6, $t6, $t2 # address of map2[i][j]
    li $t7, '.'       # Loads map[i][j] with '.'

    # Mark the current position
    sb $t7, 0($t6)    # map2[i][j] = '.'

    # Boundary checks and marking adjacent positions
    # Check for j > 0
    bgtz $s1, mark_left # If j is greater than 0, jump to mark_left
    j skip_left # Otherwise, jump to skip_left
mark_left:
    addi $t9, $t6, -1 # Calculate address of map2[i][j-1]
    sb $t7, 0($t9) # Set map2[i][j-1] to '.' (ASCII stored in $t7)
skip_left: # Label to skip marking left

    # Check for j < c-1
    addi $t8, $t1, -1 # Subtract 1 from column count c, store in $t8
    blt $s1, $t8, mark_right # If j is less than c-1, jump to mark_right
    j skip_right  # Otherwise, jump to skip_right
mark_right:
    addi $t9, $t6, 1  # Calculate address of map2[i][j+1]
    sb $t7, 0($t9) # Set map2[i][j+1] to '.' (ASCII stored in $t7)
skip_right: # Label to skip marking right

    # Check for i > 0
    bgtz $s0, mark_up  # If i is greater than 0, jump to mark_up
    j skip_up # Otherwise, jump to skip_up
mark_up:
    sub $t9, $t6, $t1 # Calculate address of map2[i-1][j]
    sb $t7, 0($t9) # Set map2[i-1][j] to '.' (ASCII stored in $t7)
skip_up: # Label to skip marking up

    # Check for i < r-1
    addi $t8, $t0, -1 # Subtract 1 from row count r, store in $t8
    blt $s0, $t8, mark_down # If i is less than r-1, jump to mark_down
    j skip_down # Otherwise, jump to skip_down
mark_down:
    add $t9, $t6, $t1  # Calculate address of map2[i+1][j]
    sb $t7, 0($t9) # Set map2[i+1][j] to '.' (ASCII stored in $t7)
skip_down:   # Label to skip marking down

skip_marking:
    addi $s1, $s1, 1  # Increment j
    j inner_loop # Jump back to the start of inner loop

end_inner_loop:
    addi $s0, $s0, 1  # Increment i
    j outer_loop # Jump back to the start of outer loop

end_outer_loop:   # End of outer loop


print:
# Print operations
 li $a0, 10        # Load ASCII value of newline into $a0
    li $v0, 11        # Load syscall code for print_char into $v0
    syscall # Print newline character
    # Print "---MAP---" and a newline after reading inputs
    li $v0, 4         # Load syscall code for print_string into $v0
    la $a0, map_header # Load address of map_header string into $a0
    syscall # Print "---MAP---\n"

    # Print Loop
    li $s0, 0         # Set i to 0
    lw $t0, r         # Load r into $t0

print_outer_loop:
    bge $s0, $t0, end_print_outer_loop # if i >= r, exit outer loop

    li $s1, 0         # j = 0, inner loop index
    lw $t1, c         # load c

print_inner_loop:
    bge $s1, $t1, end_print_inner_loop # if j >= c, exit inner loop

    # Calculate index for map2[i][j]
    mul $t2, $s0, $t1 # t2 = i * c
    add $t2, $t2, $s1 # t2 = i * c + j
    la $t3, map2 # Load address of map2 into $t3
    add $t3, $t3, $t2 # address of map2[i][j]

    lb $a0, 0($t3)    # load map2[i][j]
    li $v0, 11        # syscall for print_char
    syscall           # Print character in map2[i][j]

    addi $s1, $s1, 1  # Increment j
    j print_inner_loop # Jump back to the start of print_inner_loop


end_print_inner_loop:
    # Print newline after each row
    li $a0, 10        # Load ASCII value of newline into $a0
    li $v0, 11         # Load syscall code for print_char into $v0
    syscall            # Print newline character

    addi $s0, $s0, 1  # Increment i
    j print_outer_loop # Jump back to the start of print_outer_loop

end_print_outer_loop:
# Exit program
    li $v0, 10      # Load syscall code for exit into $v0
    syscall          # Execute exit syscall
    
