`timescale 1ns / 1ps
`include "modules/alu.sv"

module alu_tb;

    // Inputs
    logic [31:0] alu_a, alu_b;
    logic [4:0] alu_op;

    // Output
    logic [31:0] alu_result;

    // DUT
    alu dut (
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .alu_result(alu_result)
    );

    // ALU opcodes (matching those from the DUT)
    localparam ALU_ADD   = 5'b00000;
    localparam ALU_SUB   = 5'b00001;
    localparam ALU_SLL   = 5'b00010;
    localparam ALU_SLT   = 5'b00011;
    localparam ALU_SLTU  = 5'b00100;
    localparam ALU_XOR   = 5'b00101;
    localparam ALU_SRL   = 5'b00110;
    localparam ALU_SRA   = 5'b00111;
    localparam ALU_OR    = 5'b01000;
    localparam ALU_AND   = 5'b01001;
    localparam ALU_BEQ   = 5'b01010;
    localparam ALU_LUI   = 5'b01011; // Not tested, not implemented in logic
    localparam ALU_AUIPC = 5'b01100;
    localparam ALU_BNE   = 5'b01101;
    localparam ALU_BLT   = 5'b01110;
    localparam ALU_BGE   = 5'b01111;
    localparam ALU_BLTU  = 5'b10000;
    localparam ALU_BGEU  = 5'b10001;

    // Task to run a single ALU test case
    task test(input [31:0] a, input [31:0] b, input [4:0] op, input [31:0] expected, input string label);
        begin
            alu_a = a;
            alu_b = b;
            alu_op = op;
            #1; // Wait for result to propagate
            if (alu_result !== expected) begin
                $display("[FAIL] %s: Expected %h, Got %h", label, expected, alu_result);
            end else begin
                $display("[PASS] %s", label);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_tb);
        $display("=== ALU Testbench ===");

        // Arithmetic
        test(32'd10, 32'd5, ALU_ADD, 32'd15, "ADD 10 + 5");
        test(32'd10, 32'd5, ALU_SUB, 32'd5,  "SUB 10 - 5");

        // Shifts
        test(32'h0000_000F, 32'd1, ALU_SLL, 32'h0000_001E, "SLL << 1");
        test(32'h0000_00F0, 32'd4, ALU_SRL, 32'h0000_000F, "SRL >> 4");
        test(32'hFFFF_FFF0, 32'd4, ALU_SRA, 32'hFFFF_FFFF, "SRA >> 4 (signed)");

        // Comparisons
        test(32'd3, 32'd5, ALU_SLT, 32'd1,  "SLT true");
        test(32'd5, 32'd3, ALU_SLT, 32'd0,  "SLT false");
        test(32'd3, 32'd5, ALU_SLTU, 32'd1, "SLTU true");
        test(32'd5, 32'd3, ALU_SLTU, 32'd0, "SLTU false");

        // Logical ops
        test(32'h0F0F0F0F, 32'h00FF00FF, ALU_AND, 32'h000F000F, "AND");
        test(32'h0F0F0F0F, 32'h00FF00FF, ALU_OR,  32'h0FFF0FFF, "OR");
        test(32'h0F0F0F0F, 32'h00FF00FF, ALU_XOR, 32'h0FF00FF0, "XOR");

        // BEQ / BNE
        test(32'd123, 32'd123, ALU_BEQ, 32'd1, "BEQ true");
        test(32'd123, 32'd456, ALU_BEQ, 32'd0, "BEQ false");
        test(32'd123, 32'd456, ALU_BNE, 32'd1, "BNE true");
        test(32'd789, 32'd789, ALU_BNE, 32'd0, "BNE false");

        // AUIPC
        test(32'h1000_0000, 32'd4, ALU_AUIPC, 32'h1000_0004, "AUIPC add");

        // BGE / BLT
        test(-5, -10, ALU_BGE, 32'd1, "BGE true (-5 >= -10)");
        test(5, 10, ALU_BLT, 32'd1, "BLT true (5 < 10)");

        // BGEU / BLTU
        test(32'hF000_0000, 32'h1000_0000, ALU_BGEU, 32'd1, "BGEU true");
        test(32'h0000_0001, 32'h0000_0010, ALU_BLTU, 32'd1, "BLTU true");

        $display("=== ALU Test Complete ===");
        $finish;
    end

endmodule
