`timescale 1us / 1us
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
    always #0.5 clk = ~clk;

    // Initial block for test
    initial begin
        $display("Starting RISC-V processor testbench...");
        $dumpfile("top_tb.vcd"); // For GTKWave
        $dumpvars(0, top_tb);

        // Initialize signals
        clk = 0;
    
        // Run for a while
        #8;
        $display("8 ticks");
        #8;
        $display("16 ticks");
        #8;
        $display("24 ticks");
        #8;
        $display("32 ticks");
    #1000000;

        $display("Testbench finished.");
        $finish;
    end

endmodule
