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

module immed_gen(
    input logic [31:0] instruction,
    output logic [31:0] immediate
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];
    always_comb begin
        case (opcode)
            OP_LOAD, OP_JALR, OP_IMM: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            OP_STORE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            OP_BRANCH: begin
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            OP_JAL: begin
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            OP_AUIPC, OP_LUI: begin
                immediate = {instruction[31:12], 12'b0};
            end
            default: begin
                immediate = 32'b0;
            end
        endcase  
    end
endmodule