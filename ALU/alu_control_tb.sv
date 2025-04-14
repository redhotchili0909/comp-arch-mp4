`timescale 10ns/10ns
`include "alu_control.sv"

module alu_control_tb;
    // Inputs
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [6:0] opcode;
    logic       is_jalr;
    logic       is_branch;
    
    logic [3:0] alu_op;
    
    alu_control uut (
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .is_jalr(is_jalr),
        .is_branch(is_branch),
        .alu_op(alu_op)
    );
    
    localparam OP_REG     = 7'b0110011; // Register-Register operations
    localparam OP_IMM     = 7'b0010011; // Register-Immediate operations
    localparam OP_LUI     = 7'b0110111; // Load Upper Immediate
    localparam OP_AUIPC   = 7'b0010111; // Add Upper Immediate to PC
    localparam OP_LOAD    = 7'b0000011; // Load instructions
    localparam OP_STORE   = 7'b0100011; // Store instructions
    localparam OP_BRANCH  = 7'b1100011; // Branch instructions
    localparam OP_JAL     = 7'b1101111; // Jump and Link
    localparam OP_JALR    = 7'b1100111; // Jump and Link Register
    
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
    
    task check_result(input string test_name, input logic [3:0] expected);
        if (alu_op === expected)
            $display("PASS: %s - Expected: %b, Got: %b", test_name, expected, alu_op);
        else
            $display("FAIL: %s - Expected: %b, Got: %b", test_name, expected, alu_op);
    endtask
    
    initial begin
        $dumpfile("alu_control_tb.vcd");
        $dumpvars(0, alu_control_tb);
        $display("Starting ALU Control Testbench");
        
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        opcode = 7'b0000000;
        is_jalr = 0;
        is_branch = 0;
        #5;
        
        // Test Case 1: R-type ADD
        opcode = OP_REG;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #5 check_result("R-type ADD", ALU_ADD);
        
        // Test Case 2: R-type SUB
        opcode = OP_REG;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #5 check_result("R-type SUB", ALU_SUB);
        
        // Test Case 3: R-type SLL
        opcode = OP_REG;
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        #5 check_result("R-type SLL", ALU_SLL);
        
        // Test Case 4: R-type SLT
        opcode = OP_REG;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #5 check_result("R-type SLT", ALU_SLT);
        
        // Test Case 5: R-type SLTU
        opcode = OP_REG;
        funct3 = 3'b011;
        funct7 = 7'b0000000;
        #5 check_result("R-type SLTU", ALU_SLTU);
        
        // Test Case 6: R-type XOR
        opcode = OP_REG;
        funct3 = 3'b100;
        funct7 = 7'b0000000;
        #5 check_result("R-type XOR", ALU_XOR);
        
        // Test Case 7: R-type SRL
        opcode = OP_REG;
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        #5 check_result("R-type SRL", ALU_SRL);
        
        // Test Case 8: R-type SRA
        opcode = OP_REG;
        funct3 = 3'b101;
        funct7 = 7'b0100000;
        #5 check_result("R-type SRA", ALU_SRA);
        
        // Test Case 9: R-type OR
        opcode = OP_REG;
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        #5 check_result("R-type OR", ALU_OR);
        
        // Test Case 10: R-type AND
        opcode = OP_REG;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #5 check_result("R-type AND", ALU_AND);
        
        // Test Case 11: I-type ADDI
        opcode = OP_IMM;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #5 check_result("I-type ADDI", ALU_ADD);
        
        // Test Case 12: I-type SLLI
        opcode = OP_IMM;
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        #5 check_result("I-type SLLI", ALU_SLL);
        
        // Test Case 13: I-type SRLI
        opcode = OP_IMM;
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        #5 check_result("I-type SRLI", ALU_SRL);
        
        // Test Case 14: I-type SRAI
        opcode = OP_IMM;
        funct3 = 3'b101;
        funct7 = 7'b0100000;
        #5 check_result("I-type SRAI", ALU_SRA);
        
        // Test Case 15: LUI
        opcode = OP_LUI;
        #5 check_result("LUI", ALU_LUI);
        
        // Test Case 16: AUIPC
        opcode = OP_AUIPC;
        #5 check_result("AUIPC", ALU_AUIPC);
        
        // Test Case 17: LOAD
        opcode = OP_LOAD;
        #5 check_result("LOAD", ALU_ADD);
        
        // Test Case 18: STORE
        opcode = OP_STORE;
        #5 check_result("STORE", ALU_ADD);
        
        // Test Case 19: BRANCH
        opcode = OP_BRANCH;
        is_branch = 1;
        #5 check_result("BRANCH", ALU_SUB);
        is_branch = 0;
        
        // Test Case 20: JAL
        opcode = OP_JAL;
        #5 check_result("JAL", ALU_ADD);
        
        // Test Case 21: JALR
        opcode = OP_JALR;
        is_jalr = 1;
        #5 check_result("JALR", ALU_ADD);
        is_jalr = 0;
        
        $display("ALU Control Testbench Complete");
        $finish;
    end
endmodule