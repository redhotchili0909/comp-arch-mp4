`timescale 10ns/10ns
`include "alu.sv"

module alu_tb;
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_op;
    
    logic [31:0] result;
    logic        zero;
    logic        less_than;
    logic        less_than_u;
    
    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero),
        .less_than(less_than),
        .less_than_u(less_than_u)
    );
    
    // ALU operation codes
    localparam ALU_ADD   = 4'b0000;
    localparam ALU_SUB   = 4'b0001;
    localparam ALU_SLL   = 4'b0010;
    localparam ALU_SLT   = 4'b0011;
    localparam ALU_SLTU  = 4'b0100;
    localparam ALU_XOR   = 4'b0101;
    localparam ALU_SRL   = 4'b0110;
    localparam ALU_SRA   = 4'b0111;
    localparam ALU_OR    = 4'b1000;
    localparam ALU_AND   = 4'b1001;
    localparam ALU_LUI   = 4'b1010;
    localparam ALU_AUIPC = 4'b1011;
    
    task check_result(
        input string test_name, 
        input logic [31:0] expected_result,
        input logic        expected_zero,
        input logic        expected_less_than,
        input logic        expected_less_than_u
    );
        if ((result === expected_result) &&
            (zero === expected_zero) &&
            (less_than === expected_less_than) &&
            (less_than_u === expected_less_than_u)) 
        begin
            $display("PASS: %s", test_name);
        end
        else begin
            $display("FAIL: %s", test_name);
            $display("  Expected: result=%h, zero=%b, less_than=%b, less_than_u=%b", 
                     expected_result, expected_zero, expected_less_than, expected_less_than_u);
            $display("  Got:      result=%h, zero=%b, less_than=%b, less_than_u=%b", 
                     result, zero, less_than, less_than_u);
        end
    endtask
    
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
        $display("Starting ALU Testbench");
        
        a = 32'h00000000;
        b = 32'h00000000;
        alu_op = 4'b0000;
        #5;
        
        // Test #1: ADD (5 + 3)
        a = 32'h00000005;
        b = 32'h00000003;
        alu_op = ALU_ADD;
        #5;
        check_result("ADD (5+3)", 32'h00000008, 1'b0, 1'b0, 1'b0);
        
        // Test #2: ADD (-5 + 3)
        a = 32'hFFFFFFFB; // -5 in signed
        b = 32'h00000003; 
        alu_op = ALU_ADD;
        #5;
        check_result("ADD (-5+3)", 32'hFFFFFFFE, 1'b0, 1'b1, 1'b0);
        
        // Test #3: SUB (8 - 3)
        a = 32'h00000008;
        b = 32'h00000003;
        alu_op = ALU_SUB;
        #5;
        check_result("SUB (8-3)", 32'h00000005, 1'b0, 1'b0, 1'b0);
        
        // Test #4: SUB (5 - 5) => zero
        a = 32'h00000005;
        b = 32'h00000005;
        alu_op = ALU_SUB;
        #5;
        check_result("SUB (5-5)", 32'h00000000, 1'b1, 1'b0, 1'b0);
        
        // Test #5: SUB (3 - 5) => negative result
        a = 32'h00000003;
        b = 32'h00000005;
        alu_op = ALU_SUB;
        #5;
        check_result("SUB (3-5)", 32'hFFFFFFFE, 1'b0, 1'b1, 1'b1);
        
        // Test #6: SLL (1 << 4)
        a = 32'h00000001;
        b = 32'h00000004;
        alu_op = ALU_SLL;
        #5;
        check_result("SLL (1<<4)", 32'h00000010, 1'b0, 1'b0, 1'b0);
        
        // Test #7: SLT (-1 < 1)
        a = 32'hFFFFFFFF; // -1 in signed
        b = 32'h00000001;
        alu_op = ALU_SLT;
        #5;
        check_result("SLT (-1<1)", 32'h00000001, 1'b0, 1'b1, 1'b0);
        
        // Test #8: SLT (5 < 3) => false
        a = 32'h00000005;
        b = 32'h00000003;
        alu_op = ALU_SLT;
        #5;
        check_result("SLT (5<3)", 32'h00000000, 1'b1, 1'b0, 1'b0);
        
        // Test #9: SLTU (0xFFFF_FFFF < 1?)
        a = 32'hFFFFFFFF; // 4294967295
        b = 32'h00000001;
        alu_op = ALU_SLTU;
        #5;
        check_result("SLTU (FFFF_FFFF<1)", 32'h00000000, 1'b1, 1'b1, 1'b0);
        
        // Test #10: XOR (0xF ^ 0x3)
        a = 32'h0000000F; // 1111
        b = 32'h00000003; // 0011
        alu_op = ALU_XOR;
        #5;
        check_result("XOR (F^3)", 32'h0000000C, 1'b0, 1'b0, 1'b0);
        
        // Test #11: SRL (0x80000000 >> 4)
        a = 32'h80000000;
        b = 32'h00000004;
        alu_op = ALU_SRL;
        #5;
        check_result("SRL (80000000>>4)", 32'h08000000, 1'b0, 1'b0, 1'b0);
        
        // Test #12: SRA (0x80000000 >>> 4)
        a = 32'h80000000;
        b = 32'h00000004;
        alu_op = ALU_SRA;
        #5;
        check_result("SRA (80000000>>>4)", 32'hF8000000, 1'b0, 1'b1, 1'b0);
        
        // Test #13: SRA (0xF0000000 >>> 4)
        a = 32'hF0000000; // negative in signed
        b = 32'h00000004;
        alu_op = ALU_SRA;
        #5;
        check_result("SRA (F0000000>>>4)", 32'hFF000000, 1'b0, 1'b1, 1'b0);
        
        // Test #14: OR (0xA | 0x5)
        a = 32'h0000000A; // 1010
        b = 32'h00000005; // 0101
        alu_op = ALU_OR;
        #5;
        check_result("OR (A|5)", 32'h0000000F, 1'b0, 1'b0, 1'b0);
        
        // Test #15: AND (0xA & 0x3)
        a = 32'h0000000A; // 1010
        b = 32'h00000003; // 0011
        alu_op = ALU_AND;
        #5;
        check_result("AND (A&3)", 32'h00000002, 1'b0, 1'b0, 1'b0);
        
        // Test #16: LUI
        a = 32'h12345678;
        b = 32'hABCD0000;
        alu_op = ALU_LUI;
        #5;
        check_result("LUI", 32'hABCD0000, 1'b0, 1'b1, 1'b0);
        
        // Test #17: AUIPC
        a = 32'h00001000; // PC value
        b = 32'h00002000; // immediate
        alu_op = ALU_AUIPC;
        #5;
        check_result("AUIPC", 32'h00003000, 1'b0, 1'b0, 1'b0);
        
        // Test #18: Zero result check (ADD zero + zero)
        a = 32'h00000000;
        b = 32'h00000000;
        alu_op = ALU_ADD;
        #5;
        check_result("ADD (zero result)", 32'h00000000, 1'b1, 1'b0, 1'b0);

        $display("ALU Testbench Complete");
        $finish;
    end
endmodule
