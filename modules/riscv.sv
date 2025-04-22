`include "alu.sv"
`include "control.sv"
`include "immed_gen.sv"
`include "program_counter.sv"
`include "register_file.sv"
`include "state_machine.sv"

module risc_v (
    input logic clk,

    output logic memory_wen, // enable writing to memory
    output logic [31:0] memory_ra, // memory read address
    output logic [31:0] memory_wa, // memory write address

    input logic [31:0] memory_rd, // memory read data
    output logic [31:0] memory_wd, // memory write data
    output logic [2:0] memory_func3 // function code for controlling memory operation
);

logic [31:0] instruction;
logic [31:0] immediate;
logic [31:0] alu_result;

/*
MUXes for controlling signal flow
*/
logic [1:0] rd_source; // MUX for controlling register data input
logic [1:0] pc_source; // MUX for controlling program counter pointer source
logic [1:0] alu_source; // MUX for controlling alu source

logic [4:0] alu_op; // Port for controlling ALU operation

/*
Write enables for register (memory initialized as output)
*/
logic reg_wen;

/*
Struct for easier opcode management
*/
typedef enum logic [2:0] {
    U_TYPE,
    J_TYPE,
    R_TYPE,
    I_TYPE,
    S_TYPE,
    B_TYPE
  } instruction_t;

instruction_t instruction_type;

typedef enum logic [1:0] {
    IS_STORE,
    IS_LOAD,
    IS_BRANCH,
    IS_JAL
} action_t;

action_t action_type;


/*
Define constant opcode values
*/
localparam logic [6:0] OP_LUI = 7'b0110111;
localparam logic [6:0] OP_AUIPC = 7'b0010111;
localparam logic [6:0] OP_JAL = 7'b1101111;
localparam logic [6:0] OP_JALR = 7'b1100111;
localparam logic [6:0] OP_BRANCH = 7'b1100011;
localparam logic [6:0] OP_LOAD = 7'b0000011;
localparam logic [6:0] OP_STORE = 7'b0100011;
localparam logic [6:0] OP_REG = 7'b0110011;
localparam logic [6:0] OP_IMM = 7'b0010011;


logic [6:0] opcode;
logic [2:0] func3;
logic [6:0] func7;

assign opcode = instruction[6:0];
assign func3 = instruction[14:12];
assign func7 = instruction[31:25];


always_comb begin
    case (opcode)
        OP_STORE: action_type = IS_STORE;
        OP_LOAD : action_type = IS_LOAD;
        OP_BRANCH : action_type = IS_BRANCH;
        OP_JAL: action_type = IS_JAL;
        default: action_type = IS_LOAD;
    endcase
end


/*
Initialize Control Module
*/
control u_control(
    .opcode(opcode),
    .func3(func3),
    .func7(func7),
    .alu_op(alu_op),
    .alu_source(alu_source),
    .pc_source(pc_source),
    .rd_source(rd_source),
    .instruction_type(instruction_type)
);

/*
Setup Register File Logic
*/
logic [4:0] rs1, rs2, rd;
logic [31:0] rs1_data, rs2_data, rdv;
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];

/*
Initialize Register File
*/
register_file u_register_file (
    .clk(clk),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rdv(rdv),
    .reg_wen(reg_wen)
);

/*
Initialize Immediate Generator
*/
immed_gen u_immed_gen(
    .instruction(instruction),
    .immediate(immediate)
);

/*
Setup Program Counter Logic
*/
logic[31:0] pc_in, pc_out;

/*
Initialize Program Counter
*/
program_counter u_program_counter(
    .pc_source(pc_source),
    .rs1_data(rs1_data),
    .immediate(immediate),
    .alu_result(alu_result),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

/*
Setup ALU Logic
*/
// external to ALU, for the rdv input for JAL and JALR, we will just have a constant PC + 4 path ready.
// in addition, for LUI we will just have a constant path from immediate to rdv
logic [31:0] alu_a, alu_b; //alu operands
always_comb begin
    case(alu_source)
        2'b00: begin
            alu_a = rs1_data;
            alu_b = rs2_data;
        end
        2'b01: begin
            alu_a = rs1_data;
            alu_b = immediate;
        end
        2'b10: begin //auipc
            alu_a = pc_in;
            alu_b = immediate;
        end
        default: begin
            alu_a = rs1_data;
            alu_b = rs2_data;
        end
    endcase
end
/*
Initialize ALU
*/
alu u_alu(
    .alu_a(alu_a),
    .alu_b(alu_b),
    .alu_op(alu_op),
    .alu_result(alu_result)
);

/*
Initialize State Machine
*/

state_machine u_state_machine(
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

always_comb begin
    case (rd_source)
        2'b00: rdv = alu_result; // IMM & REG & AUIPC
        2'b01: rdv = pc_out + 4; // JAL & JALR
        2'b10: rdv = memory_rd; // LOAD
        2'b11: rdv = immediate; // LUI
        default: rdv = 32'b0; // Don't write anything
    endcase
end

// Assign memory data paths
assign memory_wa = rs1_data + immediate;
assign memory_wd = rs2_data;


endmodule