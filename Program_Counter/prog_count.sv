module program_counter(
    input logic clk,
    input logic rst_n,
    input logic isBranch,
    input logic isJump,
    input logic isJALR,
    input logic [31:0] immed, 
    input logic [31:0] rs1_data,

    output logic [31:0] pc
);

    logic [31:0] PC_increment;
    logic [31:0] PC_immed;
    logic [31:0] PC_rs1;

    assign PC_increment = pc + 4; // Increment PC by 4 for normal operation
    assign PC_immed = pc + immed; // Increment PC by immediate for jump and branch
    assign PC_rs1 = rs1_data + immed; // Increment PC by rs1_data + immediate for JALR
  
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
        end else begin
            if (isJump || isBranch) begin
                pc <= PC_immed;
            end else if (isJALR) begin
                pc <= PC_rs1;
            end else begin
                pc <= PC_increment;
            end
        end
    end
endmodule