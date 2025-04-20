`timescale 1ns / 1ps
`include "modules/register_file.sv"

module register_file_tb;

    // Testbench signals
    logic clk;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] rdv;
    logic reg_wen;
    logic [31:0] rs1_data, rs2_data;

    // Instantiate DUT
    register_file dut (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rdv(rdv),
        .reg_wen(reg_wen),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Clock generation
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

    initial begin
        $dumpfile("register_file_tb.vcd");
        $dumpvars(0, register_file_tb);
        // Initialize
        clk = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        rdv = 0;
        reg_wen = 0;

        // Wait for initialization
        $display("=== Register File Test ===");
        tick;

        $display("Writing 0xDEAEEFFA to x5");
        rd = 5'd5;
        rdv = 32'hDEAEEFFA;
        reg_wen = 1;
        tick;

        // Test: Read x5 -> rs1
        $display("Reading from x5 into rs1");
        rs1 = 5'd5;
        reg_wen = 0;
        tick;
        $display("rs1_data = 0x%08X (expected: 0xDEAEEFFA)", rs1_data);

        // Test: Zero register x0 always reads as 0
        $display("Reading from x0 into rs2");
        rs2 = 5'd0;
        tick;
        $display("rs2_data = 0x%08X (expected: 0x00000000)", rs2_data);

        // Test: Write to x0 (should be ignored)
        $display("Attempting to write 0x12345678 to x0");
        rd = 5'd0;
        rdv = 32'h12345678;
        reg_wen = 1;
        tick;

        // Read back x0
        rs1 = 5'd0;
        reg_wen = 0;
        tick;
        $display("x0 readback = 0x%08X (expected: 0x00000000)", rs1_data);

        // Test: Forwarding logic (rd == rs1 during write)
        $display("Testing bypass (rd == rs1)");
        rd = 5'd10;
        rs1 = 5'd10;
        rdv = 32'hCAFECAFE;
        reg_wen = 1;
        tick;
        $display("Bypassed rs1_data = 0x%08X (expected: 0xCAFECAFE)", rs1_data);

        // Done
        $display("=== Test Complete ===");
        $finish;
    end

endmodule
