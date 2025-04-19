module prog_count (
    input logic clk,
    input logic pc_write,
    input logic isBranch,
    input logic isJump,
    input logic isJALR,
    input logic take_branch,
    input logic [31:0] immed, 
    input logic [31:0] rs1_data,

    output logic [31:0] pc
);

    initial pc = 32'h0000_0000; // Initialize pc to 0

    logic [31:0] PC_increment;
    logic [31:0] PC_immed;
    logic [31:0] PC_rs1;

    assign PC_increment = pc + 4; // Increment PC by 4 for normal operation
    assign PC_immed = pc + immed; // Increment PC by immediate for jump and branch
    assign PC_rs1 = rs1_data + immed; // Increment PC by rs1_data + immediate for JALR
  
    always_ff @(posedge clk) begin
        if (pc_write) begin 
            if (isJump || (isBranch && take_branch)) begin
                pc <= PC_immed;
            end else if (isJALR) begin
                pc <= PC_rs1;
            end else begin
                pc <= PC_increment;
            end
        end
    end
endmodule