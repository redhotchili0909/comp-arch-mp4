module reg_file(
    input logic clk,
    input logic rst_n, //reset
    input logic w_en, //write enable
    input logic [4:0] rs1, //source register 1
    input logic [4:0] rs2, //source register 2
    input logic [4:0] rd, //destination register
    input logic [31:0] rdv, //write data
    
    output logic [31:0] rs1_data, //read data 1
    output logic [31:0] rs2_data //read data 2
);

logic [31:0] registers [0:31]; //32 registers of 32 bits each

// Init registers to 0
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) begin
            registers[i] <= 32'b0;
        end
    end else if (w_en && rd != 5'b0) begin // Write to register if w_en is high and rd is not zero register
        registers[rd] <= rdv;
    end
end

assign rs1_data = (rs1 == 5'b0) ? 32'b0 : registers[rs1]; // Read data from rs1
assign rs2_data = (rs2 == 5'b0) ? 32'b0 : registers[rs2]; // Read data from rs2

endmodule