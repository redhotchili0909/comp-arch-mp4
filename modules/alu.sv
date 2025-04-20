module alu(
    input logic [31:0] alu_a,
    input logic [31:0] alu_b,
    input logic [3:0] alu_op,
    output logic [31:0] alu_result
);

   /* 
    Define constant ALU operations
    */
    localparam ALU_ADD   = 5'b00000;
    localparam ALU_SUB   = 5'b00001;
    localparam ALU_SLL   = 5'b00010;
    localparam ALU_SLT   = 5'b00011;
    localparam ALU_SLTU  = 5'b00100;
    localparam ALU_XOR   = 5'b00101;
    localparam ALU_SRL   = 5'b00110;
    localparam ALU_SRA   = 5'b00111;
    localparam ALU_OR    = 5'b01000;
    localparam ALU_AND   = 5'b01001;
    localparam ALU_BEQ   = 5'b01010;
    localparam ALU_LUI   = 5'b01011;
    localparam ALU_AUIPC = 5'b01100;
    localparam ALU_BNE   = 5'b01101;
    localparam ALU_BLT   = 5'b01110;
    localparam ALU_BGE   = 5'b01111; 
    localparam ALU_BLTU  = 5'b10000;
    localparam ALU_BGEU  = 5'b10001; 

    logic [31:0] add_sub_result;
    logic [31:0] shift_amount;

    logic signed_lt;
    logic unsigned_lt;
    logic equal;

    assign shift_amount = {27'b0, alu_b[4:0]};

    assign equal = (alu_a == alu_b);
    assign signed_lt = ($signed(alu_a) < $signed(alu_b));
    assign unsigned_lt = (alu_a < alu_b);
    always_comb begin
        if (alu_op == ALU_SUB)
            add_sub_result = (alu_a - alu_b);
        else
            add_sub_result = (alu_a + alu_b);
    end

    always_comb begin
        case (alu_op)
            ALU_ADD, ALU_SUB: alu_result = add_sub_result;
            ALU_SLL:          alu_result = alu_a << shift_amount;
            ALU_SLT:          alu_result = {31'b0, signed_lt};
            ALU_SLTU:         alu_result = {31'b0, unsigned_lt};
            ALU_XOR:          alu_result = alu_a ^ alu_b;
            ALU_SRL:          alu_result = alu_a >> shift_amount;
            ALU_SRA:          alu_result = $signed(alu_a) >>> shift_amount;
            ALU_OR:           alu_result = alu_a | alu_b;
            ALU_AND:          alu_result = alu_a & alu_b;
            ALU_AUIPC:        alu_result = add_sub_result;

            ALU_BEQ:          alu_result = {31'b0, equal};
            ALU_BNE:          alu_result = {31'b0, !equal};
            ALU_BLT:          alu_result = {31'b0, signed_lt};
            ALU_BGE:          alu_result = {31'b0, !signed_lt};
            ALU_BLTU:         alu_result = {31'b0, unsigned_lt};
            ALU_BGEU:         alu_result = {31'b0, !unsigned_lt};
            default:          alu_result = 32'b0;
        endcase
    end
endmodule