`timescale 1ns / 1ps

`include "modules/program_counter.sv"

module program_counter_tb;

    // Inputs
    logic [1:0] pc_source;
    logic [31:0] rs1_data;
    logic [31:0] immediate;
    logic [31:0] alu_result;
    logic [31:0] pc_in;

    // Output
    logic [31:0] pc_out;

    // Instantiate the DUT
    program_counter dut (
        .pc_source(pc_source),
        .rs1_data(rs1_data),
        .immediate(immediate),
        .alu_result(alu_result),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Task to display current test case
    task display_state(string label);
        $display("[%0t] %s", $time, label);
        $display("  pc_source = %b", pc_source);
        $display("  rs1_data  = 0x%08x", rs1_data);
        $display("  immediate = 0x%08x", immediate);
        $display("  alu_result= 0x%08x", alu_result);
        $display("  pc_in     = 0x%08x", pc_in);
        $display("  pc_out    = 0x%08x\n", pc_out);
    endtask

    initial begin
        $display("Starting program_counter testbench...");
        $dumpfile("program_counter_tb.vcd");
        $dumpvars(0, program_counter_tb);

        // Initial inputs
        pc_in = 32'h1000;
        rs1_data = 32'h2000;
        immediate = 32'h00000010;  // 16 decimal
        alu_result = 32'h00000001; // Used in pc_source = 2

        // Test Case 0: pc_source = 2'b00 -> pc_rs1 = rs1_data + immediate
        pc_source = 2'b00;
        #1; display_state("Test Case 0: JALR (rs1 + imm)");

        // Test Case 1: pc_source = 2'b01 -> pc_immed = pc_in + immediate
        pc_source = 2'b01;
        #1; display_state("Test Case 1: JAL / Branch (pc_in + imm)");

        // Test Case 2: pc_source = 2'b10 -> conditional branch
        // If alu_result == 1 -> take branch
        pc_source = 2'b10;
        alu_result = 32'h1;
        #1; display_state("Test Case 2a: BEQ taken");

        // Test Case 2 again: alu_result != 1 -> don't take branch
        alu_result = 32'h0;
        #1; display_state("Test Case 2b: BEQ not taken");

        // Test Case 3: default (anything else) -> increment
        pc_source = 2'b11;
        #1; display_state("Test Case 3: Default (pc_in + 4)");

        $display("Testbench completed.");
        $finish;
    end

endmodule
