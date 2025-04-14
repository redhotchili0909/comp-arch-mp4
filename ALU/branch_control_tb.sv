`timescale 10ns/10ns
`include "branch_control.sv"

module branch_control_tb;
    logic [2:0] funct3;
    logic       zero;
    logic       less_than;
    logic       less_than_u;
    logic       is_branch;
    
    logic       take_branch;
    
    branch_control uut (
        .funct3(funct3),
        .zero(zero),
        .less_than(less_than),
        .less_than_u(less_than_u),
        .is_branch(is_branch),
        .take_branch(take_branch)
    );
    
    localparam BEQ  = 3'b000;  // Branch if equal
    localparam BNE  = 3'b001;  // Branch if not equal
    localparam BLT  = 3'b100;  // Branch if less than (signed)
    localparam BGE  = 3'b101;  // Branch if greater than or equal (signed)
    localparam BLTU = 3'b110;  // Branch if less than (unsigned)
    localparam BGEU = 3'b111;  // Branch if greater than or equal (unsigned)
    
    task check_result(input string test_name, input logic expected);
        if (take_branch === expected)
            $display("PASS: %s - Expected: %b, Got: %b", test_name, expected, take_branch);
        else
            $display("FAIL: %s - Expected: %b, Got: %b", test_name, expected, take_branch);
    endtask
    
    initial begin
        $dumpfile("branch_control_tb.vcd");
        $dumpvars(0, branch_control_tb);
        $display("Starting Branch Control Testbench");
        
        funct3 = 3'b000;
        zero = 0;
        less_than = 0;
        less_than_u = 0;
        is_branch = 0;
        #5;
        
        // Test non-branch instruction
        is_branch = 0;
        funct3 = BEQ;
        zero = 1;
        #5 check_result("Not branch instr", 0);
        
        is_branch = 1;
        
        // Test Case 1: BEQ - Branch if equal (zero=1)
        funct3 = BEQ;
        zero = 1;
        less_than = 0;
        less_than_u = 0;
        #5 check_result("BEQ (zero=1)", 1);
        
        // Test Case 2: BEQ - Branch if equal (zero=0)
        zero = 0;
        #5 check_result("BEQ (zero=0)", 0);
        
        // Test Case 3: BNE - Branch if not equal (zero=0)
        funct3 = BNE;
        zero = 0;
        #5 check_result("BNE (zero=0)", 1);
        
        // Test Case 4: BNE - Branch if not equal (zero=1)
        zero = 1;
        #5 check_result("BNE (zero=1)", 0);
        
        // Test Case 5: BLT - Branch if less than (less_than=1)
        funct3 = BLT;
        zero = 0;
        less_than = 1;
        #5 check_result("BLT (less_than=1)", 1);
        
        // Test Case 6: BLT - Branch if less than (less_than=0)
        less_than = 0;
        #5 check_result("BLT (less_than=0)", 0);
        
        // Test Case 7: BGE - Branch if greater or equal (less_than=0)
        funct3 = BGE;
        less_than = 0;
        #5 check_result("BGE (less_than=0)", 1);
        
        // Test Case 8: BGE - Branch if greater or equal (less_than=1)
        less_than = 1;
        #5 check_result("BGE (less_than=1)", 0);
        
        // Test Case 9: BLTU - Branch if less than unsigned (less_than_u=1)
        funct3 = BLTU;
        less_than_u = 1;
        #5 check_result("BLTU (less_than_u=1)", 1);
        
        // Test Case 10: BLTU - Branch if less than unsigned (less_than_u=0)
        less_than_u = 0;
        #5 check_result("BLTU (less_than_u=0)", 0);
        
        // Test Case 11: BGEU - Branch if greater or equal unsigned (less_than_u=0)
        funct3 = BGEU;
        less_than_u = 0;
        #5 check_result("BGEU (less_than_u=0)", 1);
        
        // Test Case 12: BGEU - Branch if greater or equal unsigned (less_than_u=1)
        less_than_u = 1;
        #5 check_result("BGEU (less_than_u=1)", 0);
        
        // Test Case 13: Wrong funct3 code
        funct3 = 3'b010;
        #5 check_result("Invalid funct3", 0);
        
        $display("Branch Control Testbench Complete");
        $finish;
    end
endmodule