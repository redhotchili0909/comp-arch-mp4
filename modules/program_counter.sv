module program_counter(
    input logic [1:0] pc_source,
    input logic [31:0] rs1_data,
    input logic [31:0] immediate,
    input logic [31:0] alu_result,
    input logic [31:0] pc_in,
    output logic [31:0] pc_out
);

    logic [31:0] pc_increment, pc_immed, pc_rs1;
    /*
    Assign possible program counter paths
    */
    assign pc_increment = pc_in + 4; // Increment PC by 4 for normal operation
    assign pc_immed = pc_in + $signed(immediate); // JAL / Branch
    assign pc_rs1 = rs1_data + $signed(immediate); // JALR

    always_comb begin 
        case (pc_source)
        2'b00 : pc_out = pc_rs1;
        2'b01 : pc_out = pc_immed;
        2'b10 : pc_out = (alu_result == {31'b0, 1'b1}) ? pc_immed :  pc_increment;
        default : pc_out = pc_increment;
        endcase
    end

endmodule