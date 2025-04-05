module immed_gen(
    input logic [31:0] instruction,
    output logic [31:0] immediate
);
    logic [6:0] opcode; 
    logic [2:0] funct3;
    logic [6:0] funct7;
   
    assign opcode = instruction[6:0]; // Extract opcode from instruction
    assign funct3 = instruction[14:12]; // Extract funct3 from instruction
    assign funct7 = instruction[31:25]; // Extract funct7 from instruction

    always_comb begin
        case (opcode)
            7'b0000011,
            7'b1100111: begin // Load instructions (I-type) & JALR
                immediate = {{21{instruction[31]}}, instruction[30:20]};
            end
            7'b0010011: begin // Immediate arithmetic instructions (I-type)
                if (funct3 == 3'b001 || funct3 == 3'b101) begin // SLLI or SRLI/SRAI
                    immediate = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
                end else begin
                    immediate = {{21{instruction[31]}}, instruction[30:20]};
                end
            end
            7'b0100011: begin // Store instructions (S-type)
                immediate = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
            end
            7'b1100011: begin // Branch instructions (B-type)
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            7'b1101111: begin // JAL (J-type)
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            7'b0010111: begin // AUIPC (U-type)
                immediate = {instruction[31:12], 12'b0};
            end
            7'b0110111: begin // LUI (U-type)
                immediate = {instruction[31:12], 12'b0};
            end
            default: begin
                immediate = 32'b0; // Default case for unsupported opcodes
            end
        endcase
    end

endmodule