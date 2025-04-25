 typedef enum logic [2:0] {
    U_TYPE,
    J_TYPE,
    R_TYPE,
    I_TYPE,
    S_TYPE,
    B_TYPE
    } instruction_t;

module control(
    input logic [6:0] opcode,
    input logic [2:0] func3,
    input logic [6:0] func7,
    output logic [1:0] pc_source,
    output logic [1:0] rd_source,
    output logic [1:0] alu_source,
    output logic [4:0] alu_op,
    output instruction_t instruction_type
);


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

    always_comb begin
        case (opcode)
        OP_LUI, OP_AUIPC: instruction_type = U_TYPE;
        OP_JAL: instruction_type = J_TYPE;
        OP_JALR, OP_LOAD, OP_IMM: instruction_type = I_TYPE;
        OP_BRANCH: instruction_type = B_TYPE;
        OP_REG: instruction_type = R_TYPE;
        OP_STORE: instruction_type = S_TYPE;
        endcase
    end

    /*
    Set program counter MUX
    */
    always_comb begin
        case (opcode)
        OP_JAL: pc_source = 2'b01;
        OP_JALR: pc_source = 2'b00;
        OP_BRANCH: pc_source = 2'b10;
        default: pc_source = 2'b11; // pc+4
        endcase
    end

    /*
    Set Register File MUX
    */
    always_comb begin
        case (opcode)
        OP_REG, OP_IMM, OP_AUIPC: rd_source = 2'b00; // from ALU
        OP_JAL, OP_JALR : rd_source = 2'b01; // PC + 4. Get from pc_out
        OP_LOAD : rd_source = 2'b10; // from memory 
        OP_LUI : rd_source = 2'b11; // from immediate
        default : rd_source = 2'b00; // mux not used for branch instructions
        endcase
    end

    /* 
    Define constant ALU operations
    */
    localparam ALU_ADD   = 5'b00000;
    localparam ALU_SUB   = 5'b00001;
    localparam ALU_SLL   = 5'b00010;
    localparam ALU_SLT   = 5'b00011;
    localparam ALU_SLTU  = 5'b00100;
    localparam ALU_XOR   = 5'b00101;
    localparam ALU_SRL   = 5'b00110;
    localparam ALU_SRA   = 5'b00111;
    localparam ALU_OR    = 5'b01000;
    localparam ALU_AND   = 5'b01001;
    localparam ALU_BEQ   = 5'b01010;
    localparam ALU_LUI   = 5'b01011;
    localparam ALU_AUIPC = 5'b01100;
    localparam ALU_BNE   = 5'b01101;
    localparam ALU_BLT   = 5'b01110;
    localparam ALU_BGE   = 5'b01111; 
    localparam ALU_BLTU  = 5'b10000;
    localparam ALU_BGEU  = 5'b10001; 

    /*
    ALU Control Logic
    */
    always_comb begin
        case (opcode)
        OP_REG : begin
            alu_source = 2'b00; // rs1 + rs2
            unique case (func3)
                3'b000: alu_op = (func7[5]) ? ALU_SUB : ALU_ADD;
                3'b001: alu_op = ALU_SLL;
                3'b010: alu_op = ALU_SLT;
                3'b011: alu_op = ALU_SLTU;
                3'b100: alu_op = ALU_XOR;
                3'b101: alu_op = (func7[5]) ? ALU_SRA : ALU_SRL;
                3'b110: alu_op = ALU_OR;
                3'b111: alu_op = ALU_AND;
            endcase
        end
        OP_IMM: begin
            alu_source = 2'b01; // rs1 + immediate
            unique case (func3)
                3'b000: alu_op = ALU_ADD;
                3'b001: alu_op = ALU_SLL;
                3'b010: alu_op = ALU_SLT;
                3'b011: alu_op = ALU_SLTU;
                3'b100: alu_op = ALU_XOR;
                3'b101: alu_op = (func7[5]) ? ALU_SRA : ALU_SRL;
                3'b110: alu_op = ALU_OR;
                3'b111: alu_op = ALU_AND;
            endcase
        end
        OP_BRANCH: begin
            alu_source = 2'b00; // rs1 + rs2 for comparisons
            unique case (func3)
                3'b000: alu_op = ALU_BEQ;
                3'b001: alu_op = ALU_BNE;
                3'b100: alu_op = ALU_BLT;
                3'b101: alu_op = ALU_BGE;
                3'b110: alu_op = ALU_BLTU;
                3'b111: alu_op = ALU_BGEU;
            endcase
        end
        OP_AUIPC: begin
            alu_source = 2'b10; // PC + immediate
            alu_op = ALU_AUIPC;
        end
        OP_JALR: begin
            alu_source = 2'b01;
            alu_op = ALU_ADD;
        end
        default: begin
            alu_source = 2'b00; // rs1 + rs2
            alu_op = ALU_ADD; // for load, store, jal, and lui
        end
        endcase
    end
endmodule

