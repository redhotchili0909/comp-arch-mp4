`timescale 10ns/10ns
`include "alu.sv"

module alu_tb;
    // Inputs
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
    
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;
    localparam ALU_LUI  = 4'b1010;
    localparam ALU_AUIPC = 4'b1011;
    
    task check_result(
        input string test_name, 
        input logic [31:0] expected_result,
        input logic expected_zero,
        input logic expected_less_than,
        input logic expected_less_than_u
    );
        if (result === expected_result && 
            zero === expected_zero && 
            less_than === expected_less_than && 
            less_than_u === expected_less_than_u)
            $display("PASS: %s", test_name);
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
        
        // Test Case 1: ADD - Basic addition
        a = 32'h00000005;
        b = 32'h00000003;
        alu_op = ALU_ADD;
        #5 check_result("ADD (5+3)", 32'h00000008, 0, 0, 0);
        
        // Test Case 2: ADD - Addition with negative numbers
        a = 32'hFFFFFFFB;
        b = 32'h00000003;
        alu_op = ALU_ADD;
        #5 check_result("ADD (-5+3)", 32'hFFFFFFFE, 0, 1, 1);
        
        // Test Case 3: SUB - Basic subtraction
        a = 32'h00000008;
        b = 32'h00000003;
        alu_op = ALU_SUB;
        #5 check_result("SUB (8-3)", 32'h00000005, 0, 0, 0);
        
        // Test Case 4: SUB - Subtraction resulting in zero
        a = 32'h00000005;
        b = 32'h00000005;
        alu_op = ALU_SUB;
        #5 check_result("SUB (5-5)", 32'h00000000, 1, 0, 0);
        
        // Test Case 5: SUB - Subtraction with negative result
        a = 32'h00000003;
        b = 32'h00000005;
        alu_op = ALU_SUB;
        #5 check_result("SUB (3-5)", 32'hFFFFFFFE, 0, 1, 1);
        
        // Test Case 6: SLL - Shift left logical
        a = 32'h00000001;
        b = 32'h00000004;
        alu_op = ALU_SLL;
        #5 check_result("SLL (1<<4)", 32'h00000010, 0, 1, 1);
        
        // Test Case 7: SLT - Set less than (signed)
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        alu_op = ALU_SLT;
        #5 check_result("SLT (-1<1)", 32'h00000001, 0, 1, 1);
        
        // Test Case 8: SLT - Set less than (not less than)
        a = 32'h00000005;
        b = 32'h00000003;
        alu_op = ALU_SLT;
        #5 check_result("SLT (5<3)", 32'h00000000, 1, 0, 0);
        
        // Test Case 9: SLTU - Set less than unsigned
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        alu_op = ALU_SLTU;
        #5 check_result("SLTU (FFFF<1)", 32'h00000000, 1, 1, 0);
        
        // Test Case 10: XOR - Bitwise XOR
        a = 32'h0000000F;
        b = 32'h00000003;
        alu_op = ALU_XOR;
        #5 check_result("XOR (F^3)", 32'h0000000C, 0, 0, 0);
        
        // Test Case 11: SRL - Shift right logical
        a = 32'h80000000;
        b = 32'h00000004;
        alu_op = ALU_SRL;
        #5 check_result("SRL (80000000>>4)", 32'h08000000, 0, 0, 0);
        
        // Test Case 12: SRA - Shift right arithmetic (positive number)
        a = 32'h80000000;
        b = 32'h00000004;
        alu_op = ALU_SRA;
        #5 check_result("SRA (80000000>>>4)", 32'hF8000000, 0, 1, 0);
        
        // Test Case 13: SRA - Shift right arithmetic (negative number)
        a = 32'hF0000000;
        b = 32'h00000004;
        alu_op = ALU_SRA;
        #5 check_result("SRA (F0000000>>>4)", 32'hFF000000, 0, 1, 0);
        
        // Test Case 14: OR - Bitwise OR
        a = 32'h0000000A;
        b = 32'h00000005;
        alu_op = ALU_OR;
        #5 check_result("OR (A|5)", 32'h0000000F, 0, 0, 0);
        
        // Test Case 15: AND - Bitwise AND
        a = 32'h0000000A;
        b = 32'h00000003;
        alu_op = ALU_AND;
        #5 check_result("AND (A&3)", 32'h00000002, 0, 0, 0);
        
        // Test Case 16: LUI - Load Upper Immediate
        a = 32'h12345678;
        b = 32'hABCD0000;
        alu_op = ALU_LUI;
        #5 check_result("LUI", 32'hABCD0000, 0, 0, 0);
        
        // Test Case 17: AUIPC - Add Upper Immediate to PC
        a = 32'h00001000; // PC value
        b = 32'h00002000; // Immediate value
        alu_op = ALU_AUIPC;
        #5 check_result("AUIPC", 32'h00003000, 0, 0, 0);
        
        // Test Case 18: Zero result check
        a = 32'h00000000;
        b = 32'h00000000;
        alu_op = ALU_ADD;
        #5 check_result("ADD (zero result)", 32'h00000000, 1, 0, 0);
        
        $display("ALU Testbench Complete");
        $finish;
    end
endmodule