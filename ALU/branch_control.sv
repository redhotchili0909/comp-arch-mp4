module branch_control(
    input  logic [2:0] funct3,      // funct3 field from instruction
    input  logic       zero,        // Zero flag from ALU
    input  logic       less_than,   // Less than flag (signed) from ALU
    input  logic       less_than_u, // Less than flag (unsigned) from ALU
    input  logic       is_branch,   // Branch instruction flag
    output logic       take_branch  // Branch taken flag
);

    // Branch condition codes from funct3
    localparam BEQ  = 3'b000;  // Branch if equal
    localparam BNE  = 3'b001;  // Branch if not equal
    localparam BLT  = 3'b100;  // Branch if less than (signed)
    localparam BGE  = 3'b101;  // Branch if greater than or equal (signed)
    localparam BLTU = 3'b110;  // Branch if less than (unsigned)
    localparam BGEU = 3'b111;  // Branch if greater than or equal (unsigned)

    always_comb begin
        if (is_branch) begin
            case (funct3)
                BEQ:  take_branch = zero;
                BNE:  take_branch = !zero;
                BLT:  take_branch = less_than;
                BGE:  take_branch = !less_than;
                BLTU: take_branch = less_than_u;
                BGEU: take_branch = !less_than_u;
                default: take_branch = 1'b0;
            endcase
        end else begin
            take_branch = 1'b0;
        end
    end

endmodule