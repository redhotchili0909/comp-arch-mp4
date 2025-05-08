// pseudocode breakdown
// 1. Use LUI to save the correct memory-mapped command to a register file
// 2. Use XORI to set the opposite command to a separate register file
// 3. Use LUI and ADDI to set our delay between switching states
// 3. Use SW to save the initial state into memory
// 4. Increment a counter until we reach our switching state delay
// 5. Switch our state and reset the counter
// 6. Repeat the counter and loop indefinitely


lui x1, 0xFF000 # lui for led; x1 = 0xFF00_0000
xori x2, x1, -1 # xor for the led bits. x2 = 0x00FF_FFFF
lui x3, 0x5B8   # x1 = 0x5B80_0000
addi x3, x3, 0xD80 # setup for counter ~1 second
sw x2, -4(x0) # store led bits at address 0xFFFF_FFFC
addi x4, x4, 1 # increment counter by 1
blt x4, x3, -4 # branch back if counter less than our target value
addi x4, x0, 0 # reset counter back to 0
sw x1, -4(x0) # swap LED state
addi x4, x4, 1 # increment counter
blt x4, x3, -4 # branch back if counter less than target value
addi x4, x0, 0 # reset counter
jal x0, -32 # jump back to initial led state


