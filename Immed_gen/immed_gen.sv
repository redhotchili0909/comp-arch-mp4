module immed_gen(
    input logic [31:0] instruction,
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    output logic [31:0] immediate
);

    always_comb begin
        case (opcode)
            7'b0000011,
            7'b1100111: begin // Load instructions (I-type) & JALR
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0010011: begin // Immediate arithmetic instructions (I-type)
                if (funct3 == 3'b001 || funct3 == 3'b101) begin // SLLI or SRLI/SRAI
                    immediate = {27'b0, instruction[24:20]}; // shamt = rdv[24:20]
                end else begin
                    immediate = {{20{instruction[31]}}, instruction[31:20]};
                end
            end
            7'b0100011: begin // Store instructions (S-type)
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin // Branch instructions (B-type)
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            7'b1101111: begin // JAL (J-type)
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            7'b0010111,
            7'b0110111: begin // AUIPC (U-type) / LUI 
                immediate = {instruction[31:12], 12'b0};
            end
            default: begin
                immediate = 32'b0; // Default case for unsupported opcodes
            end
        endcase
    end
endmodule