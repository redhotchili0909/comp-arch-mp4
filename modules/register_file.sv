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

    /*
    Initialize Registers
    */
    logic [31:0] registers [0:31]; // 32 registers of 32 bits
    initial begin
        for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (reg_wen && rd != 5'b0) begin // Write to register if reg_wen is high and rd is not zero register
        registers[rd] <= rdv;
        end
    end

    /*
    Read rdv directly if rd == rs1 or rd == rs2 and reg_wen is high
    */
    assign rs1_data = (rs1 == 5'd0) ? 32'd0 :
                  (rs1 == rd && reg_wen) ? rdv : registers[rs1];

    assign rs2_data = (rs2 == 5'd0) ? 32'd0 :
                  (rs2 == rd && reg_wen) ? rdv : registers[rs2];

endmodule