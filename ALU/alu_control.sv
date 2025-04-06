module alu_control(
    input  logic [2:0] funct3,      // funct3 field from instruction
    input  logic [6:0] funct7,      // funct7 field from instruction
    input  logic [6:0] opcode,      // opcode field from instruction
    input  logic       is_jalr,     // JALR instruction flag
    input  logic       is_branch,   // Branch instruction flag
    output logic [3:0] alu_op       // ALU operation code
);

    // ALU operation codes
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;
    localparam ALU_LUI  = 4'b1010;
    localparam ALU_AUIPC = 4'b1011;

    // RISC-V opcodes
    localparam OP_REG     = 7'b0110011; // Register-Register operations
    localparam OP_IMM     = 7'b0010011; // Register-Immediate operations
    localparam OP_LUI     = 7'b0110111; // Load Upper Immediate
    localparam OP_AUIPC   = 7'b0010111; // Add Upper Immediate to PC
    localparam OP_LOAD    = 7'b0000011; // Load instructions
    localparam OP_STORE   = 7'b0100011; // Store instructions
    localparam OP_BRANCH  = 7'b1100011; // Branch instructions
    localparam OP_JAL     = 7'b1101111; // Jump and Link
    localparam OP_JALR    = 7'b1100111; // Jump and Link Register

    always_comb begin
        alu_op = ALU_ADD;
        
        case (opcode)
            OP_REG: begin
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end
            
            OP_IMM: begin
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end
            
            OP_LUI:   alu_op = ALU_LUI;
            OP_AUIPC: alu_op = ALU_AUIPC;
            
            OP_LOAD:  alu_op = ALU_ADD;
            OP_STORE: alu_op = ALU_ADD;
            
            OP_BRANCH: begin
                alu_op = ALU_SUB;
            end
            
            OP_JAL:   alu_op = ALU_ADD;
            OP_JALR:  alu_op = ALU_ADD;
            
            default:  alu_op = ALU_ADD;
        endcase
    end

endmodule