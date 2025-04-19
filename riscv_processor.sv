`include "Instruction_Decoder/instruct_decoder.sv"
`include "Immed_gen/immed_gen.sv"
`include "Register_File/reg_file.sv"
`include "riscv_fsm.sv"
`include "memory.sv"
`include "Program_Counter/prog_count.sv"
`include "ALU/alu_control.sv"
`include "ALU/alu.sv"
`include "ALU/branch_control.sv"

module riscv_processor(
    input logic clk,
    input logic rst_n,
    output logic fetch_cycle,
    output logic pc_write,
    output logic led,
    output logic red,
    output logic green,
    output logic blue,
    output logic is_branch,
    output logic is_jal,
    output logic is_jalr,
    output logic take_branch,
    output logic [31:0] pc,
    output logic [31:0] instruction_reg,
    output logic [31:0] immediate,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_result,
    output logic [2:0] current_state
);
    // Internal signals
    //logic [31:0] pc;                // Program Counter
    //logic [31:0] instruction_reg;   // Instruction register
    //logic [31:0] immediate;         // Immediate value
    //logic [31:0] rs1_data, rs2_data; // Register file outputs
    //logic [31:0] alu_result;        // ALU result
    logic [31:0] alu_result_reg;    // ALU result register
    logic [31:0] read_data;         // Memory read data
    logic [31:0] mem_data_reg;      // Memory data register
    logic [31:0] write_data;        // Data to write to register
    
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    
    // Control signals
    logic zero;                     // ALU zero flag
    logic less_than;                // ALU less than (signed) flag
    logic less_than_u;              // ALU less than (unsigned) flag
    //logic take_branch;              // Branch decision
    //logic pc_write;                 // PC write enable
    logic ir_write;                 // Instruction register write enable
    logic reg_write;                // Register write enable
    logic mem_write;                // Memory write enable
    logic mem_read;                 // Memory read enable
    //logic is_branch;                // Branch instruction flag
    //logic is_jal, is_jalr;          // Jump instruction flags
    
    // ALU control signals
    logic [3:0] alu_op;             // ALU operation
    logic [31:0] alu_a, alu_b;      // ALU inputs
    logic [1:0] alu_src_a;          // ALU input A select
    logic [1:0] alu_src_b;          // ALU input B select
    logic [1:0] wb_sel;             // Write-back select
    
    // Instruction fields
    logic [2:0] funct3;             // funct3 field from instruction
    logic [6:0] funct7;             // funct7 field from instruction
    logic [6:0] opcode;             // opcode field from instruction

    logic [2:0] mem_funct3;         // funct3 for memory operations
    //logic fetch_cycle;             // Fetch cycle indicator
    logic mem_ready;              // Memory ready signal

    // Program Counter module
    prog_count pc_module(
        .clk(clk),
        .pc_write(pc_write),
        .isBranch(is_branch && take_branch && pc_write),
        .isJump(is_jal && pc_write),
        .isJALR(is_jalr && pc_write),
        .immed(immediate),
        .rs1_data(rs1_data),
        .pc(pc)
    );

    // Instruction Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction_reg <= 32'h0;
        end else if (ir_write) begin
            instruction_reg <= read_data;
        end
    end

    // ALU Result Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_reg <= 32'h0;
        end else begin
            alu_result_reg <= alu_result;
        end
    end

    // Memory Data Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_data_reg <= 32'h0;
        end else if (mem_ready) begin
            mem_data_reg <= read_data;
        end
    end

    always_comb begin
        if (fetch_cycle)           // top priority
            mem_funct3 = 3'b010;   // 32‑bit instruction fetch
        else if (mem_write)        // store
            mem_funct3 = funct3;
        else if (mem_read)         // load
            mem_funct3 = funct3;
        else
            mem_funct3 = 3'b010;   // idle default (doesn’t really matter)
    end

    // Memory module for instruction and data
    memory #(
        .INIT_FILE("BradTest/rv32i_test.txt")  // memory file
    ) memory_module(
        .clk(clk),
        .write_mem(mem_write),
        .funct3(mem_funct3),
        .write_address(alu_result_reg),
        .mem_read(mem_read),
        .mem_ready(mem_ready),
        .write_data(rs2_data),
        .read_address(fetch_cycle ? pc : alu_result_reg),
        .read_data(read_data),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );

    // Instruction Decoder
    instruction_decoder decoder(
        .instruction(instruction_reg),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    // Immediate Generator
    immed_gen immed_generator(
        .instruction(instruction_reg),
        .opcode(opcode),
        .funct3(funct3),
        .immediate(immediate)
    );

    // Register File
    reg_file registers(
        .clk(clk),
        .w_en(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rdv(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ALU Control
    alu_control alu_ctrl(
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .is_jalr(is_jalr),
        .is_branch(is_branch),
        .alu_op(alu_op)
    );

    // ALU input A multiplexer
    always_comb begin
        case(alu_src_a)
            2'b00: alu_a = rs1_data;      // From register file
            2'b01: alu_a = pc;            // From PC
            2'b10: alu_a = 32'b0;         // Zero
            default: alu_a = rs1_data;
        endcase
    end

    // ALU input B multiplexer
    always_comb begin
        case(alu_src_b)
            2'b00: alu_b = rs2_data;      // From register file
            2'b01: alu_b = immediate;     // From immediate generator
            2'b10: alu_b = 32'd4;         // Constant 4 (for PC+4)
            default: alu_b = rs2_data;
        endcase
    end

    // ALU module
    alu alu_module(
        .a(alu_a),
        .b(alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero),
        .less_than(less_than),
        .less_than_u(less_than_u)
    );

    // Branch Control
    branch_control branch_ctrl(
        .funct3(funct3),
        .zero(zero),
        .less_than(less_than),
        .less_than_u(less_than_u),
        .is_branch(is_branch),
        .take_branch(take_branch)
    );

    // Write-back multiplexer
    always_comb begin
        case(wb_sel)
            2'b00: write_data = alu_result_reg;  // ALU result
            2'b01: write_data = mem_data_reg;    // Memory read data
            2'b10: write_data = pc + 4;          // PC + 4 (for JAL/JALR)
            default: write_data = alu_result_reg;
        endcase
    end

    // Control Unit (State Machine)
    control_unit fsm(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .take_branch(take_branch),
        .mem_ready(mem_ready),
        .fetch_cycle(fetch_cycle),
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
        .wb_sel(wb_sel),
        .current_state(current_state)
    );

endmodule