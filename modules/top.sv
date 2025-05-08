`include "riscv.sv"
`include "memory_alt.sv"

module top (
    input logic clk,
    output logic LED,
    output logic RGB_R,
    output logic RGB_B,
    output logic RGB_G
);

    // uncomment for synthesis
    
    //logic clk;
    //SB_HFOSC #(
    //   .CLKHF_DIV("0b11")  // 48 MHz; 0b00 = 48 MHz, 0b01 = 24 MHz, 0b10 = 12 MHz, 0b11 = 6 MHz
    //) hfosc_inst (
       //.CLKHFEN(1'b1),
      // .CLKHFPU(1'b1),
     //.CLKHF  (clk)
    //);

    logic [31:0] memory_ra, memory_wa, memory_rd, memory_wd;
    logic memory_wen;
    logic [2:0] memory_func3;

    risc_v u_risc_v (
        .clk(clk),
        .memory_wen(memory_wen),
        .memory_ra(memory_ra),
        .memory_wa(memory_wa),
        .memory_rd(memory_rd),
        .memory_wd(memory_wd),
        .memory_func3(memory_func3)
    );

    memory #(
        .INIT_FILE("rgb_cycle")
    ) u_memory(
        .clk(clk),
        .write_mem(memory_wen),
        .funct3(memory_func3),
        .write_address(memory_wa),
        .write_data(memory_wd),
        .read_address(memory_ra),
        .read_data(memory_rd),
        .led(LED),
        .red(RGB_R),
        .green(RGB_G),
        .blue(RGB_B)
    );
endmodule