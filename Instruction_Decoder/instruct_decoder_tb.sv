`timescale 1ns/1ps

module instruct_decoder_tb;

    // Inputs
    logic [31:0] instruction;

    // Outputs
    logic [6:0]  opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    logic [31:0] imm_I, imm_S, imm_B, imm_U, imm_J;
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic [3:0]  alu_op;
    logic        branch;
    logic        jump;

    // Instantiate decoder
    instruction_decoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm_I(imm_I),
        .imm_S(imm_S),
        .imm_B(imm_B),
        .imm_U(imm_U),
        .imm_J(imm_J),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .branch(branch),
        .jump(jump)
    );

    
    task display_decoded;
        $display("Instruction: 0x%08h", instruction);
        $display("  opcode    = %b", opcode);
        $display("  rd        = %0d", rd);
        $display("  rs1       = %0d", rs1);
        $display("  rs2       = %0d", rs2);
        $display("  funct3    = %b", funct3);
        $display("  funct7    = %b", funct7);
        $display("  imm_I     = 0x%08h", imm_I);
        $display("  imm_S     = 0x%08h", imm_S);
        $display("  imm_B     = 0x%08h", imm_B);
        $display("  imm_U     = 0x%08h", imm_U);
        $display("  imm_J     = 0x%08h", imm_J);
        $display("  reg_write = %b", reg_write);
        $display("  mem_read  = %b", mem_read);
        $display("  mem_write = %b", mem_write);
        $display("  alu_op    = %b", alu_op);
        $display("  branch    = %b", branch);
        $display("  jump      = %b", jump);
        $display("----------------------------------------");
    endtask

    initial begin

        // ADD x1, x2, x3
        instruction = 32'b0000000_00011_00010_000_00001_0110011;
        #1 display_decoded();

        // ADDI x1, x2, 5
        instruction = 32'b000000000101_00010_000_00001_0010011;
        #1 display_decoded();

        // LW x1, 16(x2)
        instruction = 32'b000000010000_00010_010_00001_0000011;
        #1 display_decoded();

        // SW x1, 20(x2)
        instruction = 32'b0000000_00001_00010_010_10100_0100011;
        #1 display_decoded();

        // BEQ x1, x2, offset -4
        instruction = 32'b1111111_00010_00001_000_11110_1100011;
        #1 display_decoded();

        // JAL x1, offset 32
        instruction = 32'b000000000010_00000000_00000_00001_1101111;
        #1 display_decoded();

        // LUI x1, 0x12345
        instruction = 32'b00010010001101000101_00001_0110111;
        #1 display_decoded();

        $display("Instruction decoder test complete.");
        $finish;
    end

endmodule