`timescale 10ns/10ns

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

    // Instantiate the Unit Under Test (UUT)
    instruct_decoder uut (
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

    // Task to display current outputs
    task print_outputs(string name);
        $display("----- %s -----", name);
        $display("opcode   = %b", opcode);
        $display("rd       = %0d", rd);
        $display("rs1      = %0d", rs1);
        $display("rs2      = %0d", rs2);
        $display("funct3   = %b", funct3);
        $display("funct7   = %b", funct7);
        $display("imm_I    = %0d", imm_I);
        $display("imm_S    = %0d", imm_S);
        $display("imm_B    = %0d", imm_B);
        $display("imm_U    = %0d", imm_U);
        $display("imm_J    = %0d", imm_J);
        $display("reg_write= %b", reg_write);
        $display("mem_read = %b", mem_read);
        $display("mem_write= %b", mem_write);
        $display("alu_op   = %b", alu_op);
        $display("branch   = %b", branch);
        $display("jump     = %b", jump);
        $display("");
    endtask

    initial begin

        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, instruct_decoder_tb);

        // R-type ADD: add x1, x2, x3 -> opcode: 0110011, funct3: 000, funct7: 0000000
        instruction = 32'b0000000_00011_00010_000_00001_0110011;
        #10; print_outputs("ADD");

        // R-type SUB: sub x1, x2, x3
        instruction = 32'b0100000_00011_00010_000_00001_0110011;
        #10; print_outputs("SUB");

        // I-type ADDI: addi x1, x2, 5
        instruction = 32'b000000000101_00010_000_00001_0010011;
        #10; print_outputs("ADDI");

        // Load LW: lw x1, 8(x2)
        instruction = 32'b000000001000_00010_010_00001_0000011;
        #10; print_outputs("LW");

        // Store SW: sw x3, 12(x2)
        instruction = 32'b0000000_00011_00010_010_01100_0100011;
        #10; print_outputs("SW");

        // Branch BEQ: beq x1, x2, offset 16
        instruction = 32'b000000_00010_00001_000_00100_1100011; // 
        #10; print_outputs("BEQ");

        // Jump JAL: jal x1, offset 32
        instruction = 32'b000000000010_00000000_00001_1101111; // 
        #10; print_outputs("JAL");

        // LUI: lui x1, 0x12345
        instruction = 32'b00010010001101000101_00001_0110111;
        #10; print_outputs("LUI");

        // JALR: jalr x1, 0(x2)
        instruction = 32'b000000000000_00010_000_00001_1100111;
        #10; print_outputs("JALR");

        $finish;
    end
endmodule
