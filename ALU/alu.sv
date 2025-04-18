module alu(
    input  logic [31:0] a,          // First operand
    input  logic [31:0] b,          // Second operand
    input  logic [3:0]  alu_op,     // ALU operation
    output logic [31:0] result,     // ALU result
    output logic        zero,       // Zero flag (result == 0)
    output logic        less_than,  // Less than flag (signed)
    output logic        less_than_u // Less than flag (unsigned)
);

    // ALU operation codes
    localparam ALU_ADD  = 4'b0000;  // Addition
    localparam ALU_SUB  = 4'b0001;  // Subtraction
    localparam ALU_SLL  = 4'b0010;  // Shift left logical
    localparam ALU_SLT  = 4'b0011;  // Set less than (signed)
    localparam ALU_SLTU = 4'b0100;  // Set less than unsigned
    localparam ALU_XOR  = 4'b0101;  // Bitwise XOR
    localparam ALU_SRL  = 4'b0110;  // Shift right logical
    localparam ALU_SRA  = 4'b0111;  // Shift right arithmetic
    localparam ALU_OR   = 4'b1000;  // Bitwise OR
    localparam ALU_AND  = 4'b1001;  // Bitwise AND
    localparam ALU_LUI  = 4'b1010;  // Pass B (for LUI)
    localparam ALU_AUIPC = 4'b1011; // B + PC (for AUIPC)

    logic [31:0] add_sub_result;
    logic [31:0] sll_result;
    logic [31:0] srl_result;
    logic [31:0] sra_result;
    logic [31:0] shift_amount;
    
    logic signed_lt;
    logic unsigned_lt;

    // Shift amount (only the lower 5 bits are used)
    assign shift_amount = {27'b0, b[4:0]};

    // Compute comparison results - used for flags and SLT/SLTU operations
    assign signed_lt = $signed(a) < $signed(b);
    assign unsigned_lt = a < b;

    // Compute results for all operations
    always_comb begin
        // Addition/Subtraction
        if (alu_op == ALU_SUB)
            add_sub_result = a - b;
        else
            add_sub_result = a + b;
            
        // Shifts
        sll_result = a << shift_amount;
        srl_result = a >> shift_amount;
        sra_result = $signed(a) >>> shift_amount;
        
        // Determine final result based on operation
        case (alu_op)
            ALU_ADD, ALU_SUB:   result = add_sub_result;
            ALU_SLL:            result = sll_result;
            ALU_SLT:            result = {31'b0, signed_lt};
            ALU_SLTU:           result = {31'b0, unsigned_lt};
            ALU_XOR:            result = a ^ b;
            ALU_SRL:            result = srl_result;
            ALU_SRA:            result = sra_result;
            ALU_OR:             result = a | b;
            ALU_AND:            result = a & b;
            ALU_LUI:            result = b;
            ALU_AUIPC:          result = add_sub_result; // Using the add_sub_result for b + PC
            default:            result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);
    
    // Set less_than and less_than_u flags based on the specific operation
    always_comb begin
        case (alu_op)
            ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU: begin
                less_than = signed_lt;
                less_than_u = unsigned_lt;
            end
            
            // Shift operations -> check if result is negative
            ALU_SLL, ALU_SRL, ALU_SRA: begin
                less_than = result[31]; // Check negative
                less_than_u = 1'b0;     // Unsigned comparison would be false
            end
            
            // Same for bitwise operations
            ALU_XOR, ALU_OR, ALU_AND: begin
                less_than = result[31];
                less_than_u = 1'b0;
            end
            
            // Same for LUI and AUIPC
            ALU_LUI, ALU_AUIPC: begin
                less_than = result[31];
                less_than_u = 1'b0;
            end
            
            default: begin
                less_than = 1'b0;
                less_than_u = 1'b0;
            end
        endcase
    end

endmodule