.data
input:      .string         "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
test:       .string         "184"
# some single byte values for comparisons, loaded using lb, without a 0(ref)
charm:      .string         "m"
charu:      .string         "u"
charl:      .string         "l"
charO:      .string         "("
charC:      .string         ")"
charCO:     .string         ","

# a2 is just the string pointer now i guess. this is my first time writing any assembly
# s0 is the first num in the mul, s1 is the second num in the mul, s2 is the total

.text
    li s2, 0
    la a2, input
    #jal parseMulticharInt

loop:
    # check if the string has ended
    lb t1, 0(a2)
    beqz t1, exit

    lb t3, charm
    beq t1, t3, loopFoundM

loopContinue:
    # next character
    li t1, 1
    add a2, a2, t1

    j loop # go again

loopFoundM:
    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (u)
    lb t1, 0(a2)
    lb t3, charu
    beq t1, t3, loopFoundU

    j loop # wasn't actually a mul

loopFoundU:
    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (l)
    lb t1, 0(a2)
    lb t3, charl
    beq t1, t3, loopFoundL

    j loop # wasn't actually a mul

loopFoundL:
    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (opening backet)
    lb t1, 0(a2)
    lb t3, charO
    beq t1, t3, loopFound_O_

    j loop # wasn't actually a mul

# (opening bracket)
loopFound_O_:
    # next character
    li t1, 1
    add a2, a2, t1

    # so now this gets complicated, first just see if there is even a number here
    jal parseMulticharInt
    # fail if it was not actually a number
    li t1, -1
    beq t1, a0, loop

    # clear up some state
    li s0, 0
    li s1, 0

    # store the first num
    addi s0, a0, 0

    # check if there is a comma, parseMulticharInt already goes to the next char so
    # it should not be repeated here.
    # prepare comparison
    lb t1, 0(a2)
    lb t3, charCO
    # restart loop if comma is invalid
    bne t1, t3, loop

    # next character (should be a few nums in a real mul)
    li t1, 1
    add a2, a2, t1

    # check number
    jal parseMulticharInt
    # fail if it was not actually a number
    li t1, -1
    beq t1, a0, loop

    # store the number
    addi s1, a0, 0

    # check if it actually ends with a closing bracket.
    # prepare comparison
    lb t1, 0(a2)
    lb t3, charC
    # restart loop if closing bracket is invalid
    bne t1, t3, loop

    # everything is great! now start the actual business logic
    mul t1, s0, s1
    add s2, s2, t1

    j loop

# Arguments:
# a2: pointer to string
# Returns:
# a0: number
# Uses:
# t0: iteration count
# t1: temporary values
# t2: character/num
# t3: more temporary stuff, used here to see if it should return an error or not
parseMulticharInt:
    addi sp, sp, -8         # Allocate space on the stack
    sw ra, 0(sp)            # Save ra on the stack

    # Initialize state
    li t0, 0
    li a0, 0
    li t3, 0
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
    li t3, 1                # mark that this actually ran
    j parseMulticharIntLoop # here we go again

parseMulticharIntLoopEnd:
    # something that isn't a number came up, going back to the parseMulticharInt
    # but first, check if a0 should be marked as a failure
    beqz t3, parseMulticharIntLoopEndFailure
    ret

parseMulticharIntLoopEndFailure:
    li a0, -1
    ret

exit:
    # Exit program
    li a7, 10
    ecall