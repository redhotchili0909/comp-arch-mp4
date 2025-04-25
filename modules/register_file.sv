module register_file(
    input logic clk,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] rdv,
    input logic reg_wen,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] registers [0:31];

    // Used for bypass
    logic [4:0] last_rd;
    logic [31:0] last_rdv;
    logic last_wen;

    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'b0;
        end
        last_rd = 5'b0;
        last_rdv = 32'b0;
        last_wen = 1'b0;
    end

    always_ff @(posedge clk) begin
        if (reg_wen && rd != 5'b0) begin
            registers[rd] <= rdv;
        end
        last_rd <= rd;
        last_rdv <= rdv;
        last_wen <= reg_wen;
    end

    always_comb begin
        rs1_data = (rs1 == 5'd0) ? 32'd0 :
                   (rs1 == last_rd && last_wen) ? last_rdv : registers[rs1];

        rs2_data = (rs2 == 5'd0) ? 32'd0 :
                   (rs2 == last_rd && last_wen) ? last_rdv : registers[rs2];
    end

endmodule
