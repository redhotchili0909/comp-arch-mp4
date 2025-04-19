module reg_file(
    input logic clk,
    input logic w_en,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] rdv,
    
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] registers [0:31];

    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (w_en && rd != 5'b0) begin
            registers[rd] <= rdv;
        end
    end

    always_comb begin
        rs1_data = 32'b0;
        rs2_data = 32'b0;

        if (rs1 == 5'd0)
            rs1_data = 32'd0;
        else if (rs1 == rd && w_en)
            rs1_data = rdv;
        else
            rs1_data = registers[rs1];
            
        if (rs2 == 5'd0)
            rs2_data = 32'd0;
        else if (rs2 == rd && w_en)
            rs2_data = rdv;
        else
            rs2_data = registers[rs2];
    end
endmodule