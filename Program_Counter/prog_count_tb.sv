`timescale 10ns/ 10ns
`include "prog_count.sv"

module prog_count_tb;

    logic clk = 0;
    logic isBranch;
    logic isJump;
    logic isJALR;
    logic [31:0] immed;
    logic [31:0] rs1_data;
    logic [31:0] pc;

    prog_count u0 (
        .clk(clk),
        .isBranch(isBranch),
        .isJump(isJump),
        .isJALR(isJALR),
        .immed(immed),
        .rs1_data(rs1_data),
        .pc(pc)
    );

    always begin
        #4 clk = ~clk;
    end

    initial begin
        $dumpfile("prog_count_tb.vcd");
        $dumpvars(0, prog_count_tb);
        $display("Program Counter Test");
        $monitor("Time: %0t | isBranch=%0b | isJump=%0b | isJALR=%0b | immed=0x%08h | rs1_data=0x%08h | pc=0x%08h",
                 $time, isBranch, isJump, isJALR, immed, rs1_data, pc);

        clk = 0;
        isBranch = 0;
        isJump = 0;
        isJALR = 0;
        immed = 0;
        rs1_data = 0;


        // Cycle 1: Normal PC increment
        #8;
        immed = 32'd4;

        // Cycle 2: Branch taken (pc + immed)
        isBranch = 1;
        immed = 32'd16;
        #8;
        isBranch = 0;

        // Cycle 3: JALR (rs1_data + immed)
        isJALR = 1;
        rs1_data = 32'h1000_0000;
        immed = 32'd8;
        #8;
        isJALR = 0;

        // Cycle 4: Jump (pc + immed)
        isJump = 1;
        immed = 8;
        #8;
        isJump = 0;

        // Cycle 5: Normal PC increment
        #8;

        $display("Test Complete");
        $finish;
    end
endmodule