    lui x1, 0xFEDCC         # pc = 0x00, x1 = 0xFEDCC000
    addi x1, x1, 0xA98      # pc = 0x04, x1 = 0xFEDCBA98
    srli x2, x1, 4          # pc = 0x08, x2 = 0x0FEDCBA9
    srai x3, x1, 4          # pc = 0x0C, x3 = 0xFFEDCBA9
    xori x4, x3, -1         # pc = 0x10, x4 = 0x00123456
    addi x5, x0, 2          # pc = 0x14, x5 = 0x00000002
    add x6, x5, x4          # pc = 0x18, x6 = 0x00123458
    sub x7, x6, x4          # pc = 0x1C, x7 = 0x00000002
    sll x8, x4, x5          # pc = 0x20, x8 = 0x0048D158
    ori x9, x8, 7           # pc = 0x24, x9 = 0x0048D15F
    auipc x10, 0x12345      # pc = 0x28, x10 = 0x12345028
