`timescale 10ns/ 10ns
`include "reg_file.sv"

module reg_file_tb;

    logic clk = 0;
    logic w_en; //write enable
    logic [4:0] rs1; //source register 1
    logic [4:0] rs2; //source register 2
    logic [4:0] rd; //destination register
    logic [31:0] rdv; //write data
    
    logic [31:0] rs1_data; //read data 1
    logic [31:0] rs2_data; //read data 2

    reg_file u0 (
        .clk(clk),
        .w_en(w_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rdv(rdv),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always begin
        #4 clk = ~clk;
    end

    initial begin
        $dumpfile("reg_file_tb.vcd");
        $dumpvars(0, reg_file_tb);
        $display("Register File Test");


        // Reset
        clk = 0;
        w_en = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        rdv = 0;


        #8
        //write 0xABCD1234 to reg 5
        w_en = 1;
        rd = 5;
        rdv = 32'hABCD1234;
        #8

        //write 0x12345678 to reg 10
        rd = 10;
        rdv = 32'h12345678;
        #8

        // read back from rs1 = 5, rs2 = 10
        w_en = 0;
        rs1 = 5;
        rs2 = 10;
        #8
        $display("Read rs1 (reg[5]) = 0x%08h, expected = 0xABCD1234", rs1_data);
        $display("Read rs2 (reg[10]) = 0x%08h, expected = 0x12345678", rs2_data);

        // Attempt to write to register 0
        w_en = 1;
        rd = 0;
        rdv = 32'hFFFFFFFF;
        #8

        // Read from register
        w_en = 0;
        rs1 = 0;
        rs2 = 0;
        #8
        $display("Read rs1 (reg[0]) = 0x%08h, expected = 0x00000000", rs1_data);
        $display("Read rs2 (reg[0]) = 0x%08h, expected = 0x00000000", rs2_data);

        $display("Register File Test Complete");
        $finish;
    end
endmodule