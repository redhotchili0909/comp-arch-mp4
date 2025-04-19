`timescale 1ns/1ps
`include "riscv_processor.sv"

module riscv_tb;
  // Clock & reset
  logic        clk         = 0;
  logic        rst_n       = 0;

  // DUT interface - simplified to match existing ports
  logic        fetch_cycle;
  logic        pc_write;
  logic        led, red, green, blue;
  logic        is_branch, is_jal, is_jalr, take_branch;
  logic [31:0] pc, instruction_reg, immediate;
  logic [31:0] rs1_data, rs2_data, alu_result;
  logic [2:0]  current_state;
  logic [4:0]  debug_rd;
  logic [31:0] debug_wdata;

  integer fetch_count = 0;
  parameter TOTAL_INST = 20; // Reduced instruction count

  // Instantiate processor - make sure this matches your actual module port list
  riscv_processor dut (
    .clk            (clk),
    .rst_n          (rst_n),
    .fetch_cycle    (fetch_cycle),
    .pc_write       (pc_write),
    .led            (led),
    .red            (red),
    .green          (green),
    .blue           (blue),
    .is_branch      (is_branch),
    .is_jal         (is_jal),
    .is_jalr        (is_jalr),
    .take_branch    (take_branch),
    .pc             (pc),
    .instruction_reg(instruction_reg),
    .immediate      (immediate),
    .rs1_data       (rs1_data),
    .rs2_data       (rs2_data),
    .alu_result     (alu_result),
    .current_state  (current_state),
    .debug_rd       (debug_rd),
    .debug_wdata    (debug_wdata)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Simplified testbench
  initial begin
    $dumpfile("brad_tb.vcd");
    $dumpvars(0, riscv_tb);
    
    // Reset sequence
    rst_n = 0;
    repeat (4) @(posedge clk);
    rst_n = 1;
    
    // Run for a set number of cycles
    repeat (100) @(posedge clk);
    
    // Print final register state
    $display("\n=== FINAL REGISTER STATE ===");
    for (int i = 0; i < 32; i++) begin
      $display("  x%0d = 0x%08h", i, dut.registers.registers[i]);
    end
    
    $finish;
  end

always @(posedge clk) begin
  if (dut.current_state == 3'd1) begin // DECODE state
    $display("DECODE: alu_src_a=%d, alu_src_b=%d, immediate=0x%h",
             dut.alu_src_a, dut.alu_src_b, dut.immediate);
  end
  else if (dut.current_state == 3'd2) begin // EXECUTE state 
    $display("EXECUTE: alu_src_a=%d, alu_src_b=%d, alu_a=0x%h, alu_b=0x%h, alu_result=0x%h",
             dut.alu_src_a, dut.alu_src_b, dut.alu_a, dut.alu_b, dut.alu_result);
  end
end

  // Add to your testbench to observe critical signals
always @(posedge clk) begin
  if (dut.reg_write && dut.rd != 0) begin
    $display("REG WRITE: rd=%d, data=0x%h, wb_sel=%d, alu_result=0x%h",
             dut.rd, dut.write_data, dut.wb_sel, dut.alu_result);
  end

  if (dut.ir_write && dut.mem_ready) begin
    $display("Immediate after decode: 0x%08h", dut.immediate);
  end
    
  
  if (dut.current_state == 3'd2) begin // EXECUTE state
    $display("EXECUTE: alu_a=0x%h, alu_b=0x%h, alu_result=0x%h",
             dut.alu_a, dut.alu_b, dut.alu_result);
  end
  
  if (dut.current_state == 3'd4) begin // WRITEBACK state
    $display("WRITEBACK: alu_result_reg=0x%h, wb_sel=%d",
             dut.alu_result_reg, dut.wb_sel);
    end
    end

  // Simplified monitoring
  always @(posedge clk) begin
    if (dut.ir_write) begin
      fetch_count++;
      $display("[%0t] FETCH #%0d: PC=0x%08h, INST=0x%08h", 
               $time, fetch_count, pc, instruction_reg);
    end
    
    if (dut.reg_write && dut.rd != 0) begin
      $display("[%0t] REG WRITE: x%0d <- 0x%08h", 
               $time, dut.rd, dut.write_data);
    end
  end
endmodule