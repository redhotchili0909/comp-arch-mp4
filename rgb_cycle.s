lui x1, 0xFF000 # lui for led; x1 = 0xFF00_0000
srli x2, x1, 8 # srli to get red bit
xori x2, x2, -1 # xor red bit
srli x3, x1, 16 # srli to get green bit
xori x3, x3, -1 # xor green bit
srli x4, x1, 24 # srli to get blue bit
xori x4, x4, -1 # xor blue bit
sw x2, -4(x0) # store red bits to 0xFFFF_FFFC
lui x6, 0x5B8   # x1 = 0x5B80_0000
addi x6, x3, 0xD80 # setup for counter ~1 second
addi x7, x7, 1 # increment counter
blt x7, x6, -4 # branch back if counter less than our target value
addi x7, x0, 0 # reset counter
xor x8, x2, x3 # xor red and green bits
xori x8, x8, -1 # xori to set bits correctly
sw x8, -4(x0) # store yellow bits to 0xFFFF_FFFC
addi x7, x7, 1 # increment counter
blt x7, x6, -4 # branch back if counter less than our target value
addi x7, x0, 0 # reset counter
sw x3, -4(x0) # save green bits to 0xFFFF_FFFC
addi x7, x7, 1 # increment counter
blt x7, x6, -4 # branch back if counter less than our target value
addi x7, x0, 0 # reset counter
xor x8, x3, x4 # xor green and blue bits
xori x8, x8, -1 # xori to set bits correctly
sw x8, -4(x0) # store teal bits to 0xFFFF_FFFC
addi x7, x7, 1 # increment counter
blt x7, x6, -4 # branch back if counter less than our target value
addi x7, x0, 0 # reset counter
sw x4, -4(x0) # save blue bits to 0xFFFF_FFFC
addi x7, x7, 1 # increment counter
blt x7, x6, -4 # branch back if counter less than our target value
addi x7, x0, 0 # reset counter
xor x8, x4, x2 # xor blue and red bits
xori x8, x8, -1 # xori to set bits correctly
sw x8, -4(x0) # save purple bits to 0xFFFF_FFFC
addi x7, x7, 1 # increment counter
blt x7, x6, -4 # branch back if counter less than our target value
addi x7, x0, 0 # reset counter
jal x0, -128 # jump back to red LED state
