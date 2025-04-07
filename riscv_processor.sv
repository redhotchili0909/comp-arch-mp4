module riscv_processor(
    input  logic        clk,
    input  logic        rst_n,
    output logic        led,
    output logic        red,
    output logic        green,
    output logic        blue
);
    // Internal signals
    logic [31:0] pc;                  // Program Counter
    logic [31:0] instruction;         // Current instruction
    logic [31:0] immediate;           // Immediate value
    logic [31:0] rs1_data, rs2_data;  // Register file outputs
    logic [31:0] alu_result;          // ALU result
    logic [31:0] read_data;           // Memory read data
    logic [31:0] write_data;          // Data to write to register
    logic        zero;                // ALU zero flag
    logic        less_than;           // ALU less than (signed) flag
    logic        less_than_u;         // ALU less than (unsigned) flag
    logic        take_branch;         // Branch decision
    logic        is_branch;           // Branch instruction flag
    logic        is_jal, is_jalr;     // Jump instruction flags
    logic        reg_write;           // Register write enable
    logic        mem_write;           // Memory write enable
    logic [3:0]  alu_op;              // ALU operation
    logic [31:0] alu_a, alu_b;        // ALU inputs
    logic [2:0]  funct3;              // funct3 field from instruction
    logic [6:0]  funct7;              // funct7 field from instruction
    logic [6:0]  opcode;              // opcode field from instruction
    
    // Extract instruction fields
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Program Counter module
    program_counter pc_module(
        .clk(clk),
        .rst_n(rst_n),
        .isBranch(take_branch),
        .isJump(is_jal),
        .isJALR(is_jalr),
        .immed(immediate),
        .rs1_data(rs1_data),
        .pc(pc)
    );
    
    // Memory module for instruction and data
    memory #(
        .INIT_FILE("")  //  memory file
    ) memory_module(
        .clk(clk),
        .write_mem(mem_write),
        .funct3(funct3),
        .write_address(alu_result),
        .write_data(rs2_data),
        .read_address(is_branch || is_jal || is_jalr ? alu_result : pc),
        .read_data(read_data),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );
    
    // Assign instruction from memory when in fetch state
    assign instruction = read_data;
    
    // Immediate Generator
    immed_gen immed_generator(
        .instruction(instruction),
        .immediate(immediate)
    );
    
    // Register File
    reg_file registers(
        .clk(clk),
        .rst_n(rst_n),
        .w_en(reg_write),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
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

    

endmodule