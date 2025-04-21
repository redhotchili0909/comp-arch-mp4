`timescale 1ns / 1ps
`include "top.sv"
module top_tb();

    // Testbench signals
    logic clk;
    logic led, red, green, blue;

    // Instantiate the processor
    top u_top (
        .clk(clk),
        .LED(led),
        .RGB_R(red),
        .RGB_G(green),
        .RGB_B(blue)
    );

    // Clock generation: 10ns period
    always #4 clk = ~clk;

    // Initial block for test
    initial begin
        $display("Starting RISC-V processor testbench...");
        $dumpfile("top_tb.vcd"); // For GTKWave
        $dumpvars(0, top_tb);

        // Initialize signals
        clk = 0;
        //rst_n = 1;

        // Apply reset
        //#20;
        //rst_n = 1;

        // Run for a while
        #8;
        $display("8 ticks");
        #8;
        $display("16 ticks");
        #8;
        $display("24 ticks");
        #8;
        $display("32 ticks");
        #3200

        $display("Testbench finished.");
        $finish;
    end

endmodule
