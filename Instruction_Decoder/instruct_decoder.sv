module instruction_decoder (
    input  logic [31:0] instruction,
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7,
    output logic [31:0] imm_I, imm_S, imm_B, imm_U, imm_J,
    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic [3:0]  alu_op,
    output logic        branch,
    output logic        jump
);

    // Basic field extraction
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Immediates by type
    assign imm_I = {{20{instruction[31]}}, instruction[31:20]};
    assign imm_S = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // sign extension
    assign imm_B = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    assign imm_U = {instruction[31:12], 12'b0};
    assign imm_J = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

    // Control logic
    always_comb begin
        
        reg_write = 0;
        mem_read  = 0;
        mem_write = 0;
        branch    = 0;
        jump      = 0;
        alu_op    = 4'b0000;

        case (opcode)
            // R-type
            7'b0110011: begin
                reg_write = 1;
                case ({funct7, funct3})
                    10'b0000000000: alu_op = 4'b0000; // ADD
                    10'b0100000000: alu_op = 4'b0001; // SUB
                    10'b0000000001: alu_op = 4'b0010; // SLL
                    10'b0000000010: alu_op = 4'b0011; // SLT
                    10'b0000000011: alu_op = 4'b0100; // SLTU
                    10'b0000000100: alu_op = 4'b0101; // XOR
                    10'b0000000101: alu_op = 4'b0110; // SRL
                    10'b0100000101: alu_op = 4'b0111; // SRA
                    10'b0000000110: alu_op = 4'b1000; // OR
                    10'b0000000111: alu_op = 4'b1001; // AND
                    default:         alu_op = 4'b1111; // Illegal
                endcase
            end

            // I-type ALU
            7'b0010011: begin
                reg_write = 1;
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b010: alu_op = 4'b0011; // SLTI
                    3'b011: alu_op = 4'b0100; // SLTIU
                    3'b100: alu_op = 4'b0101; // XORI
                    3'b110: alu_op = 4'b1000; // ORI
                    3'b111: alu_op = 4'b1001; // ANDI
                    3'b001: alu_op = 4'b0010; // SLLI
                    3'b101: begin
                        if (funct7 == 7'b0000000) alu_op = 4'b0110; // SRLI
                        else if (funct7 == 7'b0100000) alu_op = 4'b0111; // SRAI
                        else alu_op = 4'b1111;
                    end
                    default: alu_op = 4'b1111;
                endcase
            end

            // LOAD
            7'b0000011: begin
                reg_write = 1;
                mem_read  = 1;
                alu_op    = 4'b0000; // ADD (address = rs1 + imm)
            end

            // STORE
            7'b0100011: begin
                mem_write = 1;
                alu_op    = 4'b0000; // ADD (address = rs1 + imm)
            end

            // BRANCH
            7'b1100011: begin
                branch = 1;
                case (funct3)
                    3'b000: alu_op = 4'b1010; // BEQ
                    3'b001: alu_op = 4'b1011; // BNE
                    3'b100: alu_op = 4'b1100; // BLT
                    3'b101: alu_op = 4'b1101; // BGE
                    3'b110: alu_op = 4'b1110; // BLTU
                    3'b111: alu_op = 4'b1111; // BGEU
                    default: alu_op = 4'b1111;
                endcase
            end

            // JAL
            7'b1101111: begin
                reg_write = 1;
                jump      = 1;
                alu_op    = 4'b0000;
            end

            // JALR
            7'b1100111: begin
                reg_write = 1;
                jump      = 1;
                alu_op    = 4'b0000;
            end

            // LUI
            7'b0110111: begin
                reg_write = 1;
                alu_op    = 4'b0000; // Pass-through of immediate
            end

            // AUIPC
            7'b0010111: begin
                reg_write = 1;
                alu_op    = 4'b0000; // PC + imm
            end

            default: begin
                alu_op = 4'b1111; // unknown
            end
        endcase
    end
endmodule