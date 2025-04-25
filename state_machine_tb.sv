`timescale 1ns / 1ps
`include "modules/state_machine.sv"
module state_machine_tb;

    // Clock
    logic clk;

    // Inputs
    action_t action_type;
    logic [31:0] memory_rd;
    logic [31:0] pc_out;
    logic [31:0] immediate;
    logic [31:0] rs1_data;
    logic [2:0] func3;

    // Outputs
    logic reg_wen;
    logic memory_wen;
    logic [31:0] memory_ra;
    logic [2:0] memory_func3;
    logic [31:0] pc_in;
    logic [31:0] instruction;

    // Instantiate the DUT
    state_machine dut (
        .clk(clk),
        .action_type(action_type),
        .memory_rd(memory_rd),
        .pc_out(pc_out),
        .immediate(immediate),
        .rs1_data(rs1_data),
        .func3(func3),
        .reg_wen(reg_wen),
        .memory_wen(memory_wen),
        .memory_ra(memory_ra),
        .memory_func3(memory_func3),
        .pc_in(pc_in),
        .instruction(instruction)
    );

    // Task to simulate a clock tick (1 full clock cycle)
    task tick;
        begin
            clk = 0;
            #1;
            clk = 1;
            #5;
            clk = 0;
            #4;
        end
    endtask

    // Stimulus
    initial begin
        $dumpfile("state_machine_tb.vcd");
        $dumpvars(0, state_machine_tb);
        // Initialize inputs
        clk = 0;
        memory_rd = 32'h0000_0000;
        pc_out = 32'h1000_0000;
        immediate = 32'h0000_0010;
        rs1_data = 32'h2000_0000;
        func3 = 3'b010;

        // Start test with a known state
        action_type = IS_LOAD;

        $display("\n=== Starting FSM test ===\n");

        // Cycle 1: LOAD
        $display("--- LOAD ---");
        tick; // FETCH
        tick; // EXECUTE
        tick; // MEMORY
        tick; // FETCH

        // Cycle 2: STORE
        $display("--- STORE ---");
        action_type = IS_STORE;
        tick; // FETCH
        tick; // EXECUTE
        tick; // MEMORY
        tick; // FETCH

        // Cycle 3: BRANCH
        $display("--- BRANCH ---");
        action_type = IS_BRANCH;
        tick; // FETCH
        tick; // EXECUTE
        tick; // FETCH

        // Cycle 4: JAL
        $display("--- JAL ---");
        action_type = IS_JAL;
        tick; // FETCH
        tick; // EXECUTE
        tick; // FETCH

        $display("\n=== End of FSM test ===");
        $finish;
    end

endmodule
