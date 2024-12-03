.data
input:      .string      "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
test:       .string      "184"

# a2 is just the string pointer now i guess. this is my first time writing any assembly

.text
    la a2, test
    jal parseMulticharInt
    j exit

# Arguments:
# a2: pointer to string
# Returns:
# a0: number
# Uses:
# t0: iteration count
# t1: temporary values
# t2: character/num
parseMulticharInt:
    addi sp, sp, -8         # Allocate space on the stack
    sw ra, 0(sp)            # Save ra on the stack

    # Initialize state
    li t0, 0
    li a0, 0
    jal parseMulticharIntLoop

    lw ra, 0(sp)            # Restore ra from the stack
    addi sp, sp, 8          # Deallocate stack space
    ret                     # Return to caller

parseMulticharIntLoop:
    lb t2, 0(a2)            # get character to parse
    li t1, -48              # prepare offset from ASCII 0 to 0
    add t2, t1, t2          # remove offset from ASCII char, should become unsigned int

    li t1, 9                # prepare value for > x
                            # exit the loop if the numbers end
                            # has to be bgtu because t2 hits the initiger limit causing it to
                            # go in the negatives, which would always skip the loop end.
    bgtu t2, t1, parseMulticharIntLoopEnd

    li t1, 10               # prepare arg for mul
    mul a0, a0, t1          # move stuff in total to left by 1 decimal point
    add a0, a0, t2          # add to total

    li t1, 1                # prepare number to add
    add t0, t0, t1          # add to iter count
    add a2, a2, t1          # move to next character
    j parseMulticharIntLoop # here we go again

parseMulticharIntLoopEnd:
    # something that isn't a number came up, going back to the parseMulticharInt
    ret

exit:
    # Exit program
    li a7, 10
    ecall