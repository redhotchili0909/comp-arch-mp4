`timescale 1ns / 1ps
`include "riscv_processor.sv"
module riscv_processor_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic led, red, green, blue;

    // Instantiate the processor
    riscv_processor u0 (
        .clk(clk),
        .rst_n(rst_n),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Initial block for test
    initial begin
        $display("Starting RISC-V processor testbench...");
        $dumpfile("riscv_processor_tb.vcd"); // For GTKWave
        $dumpvars(0, riscv_processor_tb);

        // Initialize signals
        clk = 0;
        rst_n = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Run for a while
        #1000;

        $display("Testbench finished.");
        $finish;
    end

endmodule
