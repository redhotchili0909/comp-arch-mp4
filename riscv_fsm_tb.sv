`timescale 10ns/10ns
`include "riscv_fsm.sv"

module control_unit_tb;
    logic clk;
    logic rst_n;
    logic [6:0] opcode;
    logic take_branch;
    
    logic pc_write;
    logic ir_write;
    logic reg_write;
    logic mem_write;
    logic mem_read;
    logic is_branch;
    logic is_jal;
    logic is_jalr;
    logic [1:0] alu_src_a;
    logic [1:0] alu_src_b;
    logic [1:0] wb_sel;
    
    control_unit uut (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .take_branch(take_branch),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .is_branch(is_branch),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .wb_sel(wb_sel)
    );
    
    localparam OPCODE_LOAD      = 7'b0000011;
    localparam OPCODE_STORE     = 7'b0100011;
    localparam OPCODE_BRANCH    = 7'b1100011;
    localparam OPCODE_JAL       = 7'b1101111;
    localparam OPCODE_JALR      = 7'b1100111;
    localparam OPCODE_OP_IMM    = 7'b0010011;
    localparam OPCODE_OP        = 7'b0110011;
    localparam OPCODE_LUI       = 7'b0110111;
    localparam OPCODE_AUIPC     = 7'b0010111;
    localparam OPCODE_SYSTEM    = 7'b1110011;
    
    typedef enum logic [2:0] {
        FETCH = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEM_ACCESS = 3'b011,
        WRITEBACK = 3'b100
    } state_t;
    
    always begin
        #5 clk = ~clk;
    end
    
    task display_control_signals;
        $display("Time: %0t, State: %0d", $time, uut.current_state);
        $display("  pc_write=%b, ir_write=%b, reg_write=%b, mem_write=%b, mem_read=%b", 
                 pc_write, ir_write, reg_write, mem_write, mem_read);
        $display("  is_branch=%b, is_jal=%b, is_jalr=%b", 
                 is_branch, is_jal, is_jalr);
        $display("  alu_src_a=%b, alu_src_b=%b, wb_sel=%b", 
                 alu_src_a, alu_src_b, wb_sel);
    endtask
    
    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
        $display("Starting Control Unit Testbench");
        
        clk = 0;
        rst_n = 0;
        opcode = 7'b0000000;
        take_branch = 0;
        
        #10 rst_n = 1;
        
        // Test 1: R-type instruction (ADD, SUB)
        $display("\n\nTest 1: R-type instruction");
        opcode = OPCODE_OP;
        take_branch = 0;
        
        // FETCH-DECODE-EXECUTE-WRITEBACK
        #40 display_control_signals();
        
        // Test 2: I-type instruction (ADDI)
        $display("\n\nTest 2: I-type instruction");
        opcode = OPCODE_OP_IMM;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        #40 display_control_signals();
        
        // Test 3: Load instruction (LW)
        $display("\n\nTest 3: Load instruction");
        opcode = OPCODE_LOAD;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE-MEM_ACCESS-WRITEBACK
        #50 display_control_signals();
        
        // Test 4: Store instruction (SW)
        $display("\n\nTest 4: Store instruction");
        opcode = OPCODE_STORE;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE-MEM_ACCESS
        #40 display_control_signals();
        
        // Test 5: Branch instruction (BEQ) - branch taken
        $display("\n\nTest 5: Branch instruction (taken)");
        opcode = OPCODE_BRANCH;
        take_branch = 1;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE
        #30 display_control_signals();
        
        // Test 6: Branch instruction (BEQ) - branch not taken
        $display("\n\nTest 6: Branch instruction (not taken)");
        opcode = OPCODE_BRANCH;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE
        #30 display_control_signals();
        
        // Test 7: JAL instruction
        $display("\n\nTest 7: JAL instruction");
        opcode = OPCODE_JAL;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE-WRITEBACK
        #40 display_control_signals();
        
        // Test 8: JALR instruction
        $display("\n\nTest 8: JALR instruction");
        opcode = OPCODE_JALR;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE-WRITEBACK
        #40 display_control_signals();
        
        // Test 9: LUI instruction
        $display("\n\nTest 9: LUI instruction");
        opcode = OPCODE_LUI;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE-WRITEBACK
        #40 display_control_signals();
        
        // Test 10: AUIPC instruction
        $display("\n\nTest 10: AUIPC instruction");
        opcode = OPCODE_AUIPC;
        take_branch = 0;
        
        rst_n = 0;
        #10 rst_n = 1;
        
        // FETCH-DECODE-EXECUTE-WRITEBACK
        #40 display_control_signals();
        
        $display("\nControl Unit Testbench Complete");
        $finish;
    end
    
    initial begin
        $monitor("Time: %0t, current_state=%b, next_state=%b",
                $time,
                uut.current_state,
                uut.next_state);
    end

endmodule