.data
input:      .string         "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
test:       .string         "184"
# some single byte values for comparisons, loaded using lb, without a 0(ref)
charm:      .string         "m"
charu:      .string         "u"
charl:      .string         "l"
charO:      .string         "("
charC:      .string         ")"
charCO:     .string         ","
chard:      .string         "d"
charo:      .string         "o"
charn:      .string         "n"
charA:      .string         "'"
chart:      .string         "t"

# a2 is just the string pointer now i guess. this is my first time writing any assembly
# s0 is the first num in the mul, s1 is the second num in the mul, s2 is the total
# s3 is 0 when we should just continue parsing and not wait until a do()

.text
    li s2, 0
    li s3, 0
    la a2, input

loop:
    # check if the string has ended
    lb t1, 0(a2)
    beqz t1, exit

    lb t3, chard
    beq t1, t3, loopFoundD

    # s3 is set to 1 when it should wait until a do, so this branches off to loopContinue
    bnez s3, loopContinue

    lb t3, charm
    beq t1, t3, loopFoundM

loopContinue:
    # next character
    li t1, 1
    add a2, a2, t1

    j loop # go again

loopFoundD:
    # possible do or don't statement
    # next char
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (o)
    lb t1, 0(a2)
    lb t3, charo
    bne t1, t3, loop # not a o, repeat

    # now branch to loopFoundDO if there is a opening bracket
    # don't will still be handled here

    # next char
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (opening bracket)
    lb t1, 0(a2)
    lb t3, charO
    beq t1, t3, loopFoundDO # go to loopFoundDO if there is an opening bracket, stay if there isn't

    # now check if this current character is actually a n
    lb t3, charn
    bne t1, t3, loop # go back if it's not

    # next char
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (')
    lb t1, 0(a2)
    lb t3, charA
    bne t1, t3, loop # go back if it's not

    # next char
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (t)
    lb t1, 0(a2)
    lb t3, chart
    bne t1, t3, loop # go back if it's not

    # now it's confirmed to say "don't", just the brackets left
    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (opening bracket)
    lb t1, 0(a2)
    lb t3, charO
    bne t1, t3, loop # go back if it's not

    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (closing bracket)
    lb t1, 0(a2)
    lb t3, charC
    bne t1, t3, loop # go back if it's not

    # it's confirmed to say "don't()", now update s3 to block mul's
    li s3, 1

    # jump back
    j loop

loopFoundDO:
    # now check for a closing bracket, if found this is a valid DO statement
    # next char
    li t1, 1
    add a2, a2, t1

    # load character and comparison value
    lb t1, 0(a2)
    lb t3, charC
    bne t1, t3, loop # back to parse loop

    # set s3 to allow
    li s3, 0

    # jump back
    j loop

loopFoundM:
    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (u)
    lb t1, 0(a2)
    lb t3, charu
    bne t1, t3, loop # stop if it's not a u

# u

    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (l)
    lb t1, 0(a2)
    lb t3, charl
    bne t1, t3, loop # stop if it's not an l

# l

    # next character
    li t1, 1
    add a2, a2, t1

    # load character and comparison value (opening backet)
    lb t1, 0(a2)
    lb t3, charO
    bne t1, t3, loop # stop if it's not an opening bracket

# (opening bracket)

    # next character
    li t1, 1
    add a2, a2, t1

    # parse the first number
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
