module control_unit(
    input logic clk,
    input logic rst_n,
    input logic [6:0] opcode,
    input logic take_branch,        // From branch control unit
    output logic pc_write,          // Enable PC update
    output logic ir_write,          // Enable instruction register update
    output logic reg_write,         // Enable register file write
    output logic mem_write,         // Enable memory write
    output logic mem_read,          // Enable memory read
    output logic is_branch,         // Branch instruction indicator
    output logic is_jal,            // JAL instruction indicator
    output logic is_jalr,           // JALR instruction indicator
    output logic [1:0] alu_src_a,   // ALU input A source select
    output logic [1:0] alu_src_b,   // ALU input B source select
    output logic [1:0] wb_sel       // Write-back select
);

    // RISC-V opcode definitions
    localparam OPCODE_LOAD      = 7'b0000011;
    localparam OPCODE_STORE     = 7'b0100011;
    localparam OPCODE_BRANCH    = 7'b1100011;
    localparam OPCODE_JAL       = 7'b1101111;
    localparam OPCODE_JALR      = 7'b1100111;
    localparam OPCODE_OP_IMM    = 7'b0010011;
    localparam OPCODE_OP        = 7'b0110011;
    localparam OPCODE_LUI       = 7'b0110111;
    localparam OPCODE_AUIPC     = 7'b0010111;
    localparam OPCODE_SYSTEM    = 7'b1110011;

    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM_ACCESS,
        WRITEBACK
    } state;

    state current_state, next_state;
    
    // Instruction type signals (derived from opcode)
    logic is_load, is_store, is_r_type, is_i_type, is_lui, is_auipc;
    
    // Instruction type decoder
    always_comb begin
        is_load   = (opcode == OPCODE_LOAD);
        is_store  = (opcode == OPCODE_STORE);
        is_branch = (opcode == OPCODE_BRANCH);
        is_jal    = (opcode == OPCODE_JAL);
        is_jalr   = (opcode == OPCODE_JALR);
        is_r_type = (opcode == OPCODE_OP);
        is_i_type = (opcode == OPCODE_OP_IMM);
        is_lui    = (opcode == OPCODE_LUI);
        is_auipc  = (opcode == OPCODE_AUIPC);
    end

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = current_state; // Default: stay in current state

        case (current_state)
            FETCH: 
                next_state = DECODE;
                
            DECODE:
                next_state = EXECUTE;
                
            EXECUTE: begin
                if (is_load || is_store)
                    next_state = MEM_ACCESS;
                else if (is_branch)
                    next_state = FETCH;
                else
                    next_state = WRITEBACK;
            end
                
            MEM_ACCESS: begin
                if (is_load)
                    next_state = WRITEBACK;
                else // STORE
                    next_state = FETCH;
            end
                
            WRITEBACK:
                next_state = FETCH;
                
            default:
                next_state = FETCH;
        endcase
    end

    // Output logic - Optimized with clearer signal assignment
    always_comb begin
        // Default values
        pc_write = 1'b0;
        ir_write = 1'b0;
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        alu_src_a = 2'b00;  // Default: rs1
        alu_src_b = 2'b00;  // Default: rs2
        wb_sel = 2'b00;     // Default: ALU result

        case (current_state)
            FETCH: begin
                mem_read = 1'b1;  // Read instruction from memory
                ir_write = 1'b1;  // Write to instruction register
            end

            EXECUTE: begin
                // Set ALU sources based on instruction type
                if (is_r_type) begin
                    alu_src_a = 2'b00;  // rs1
                    alu_src_b = 2'b00;  // rs2
                end
                else if (is_i_type || is_load || is_store || is_jalr) begin
                    alu_src_a = 2'b00;  // rs1
                    alu_src_b = 2'b01;  // immediate
                end
                else if (is_lui) begin
                    alu_src_a = 2'b10;  // Zero
                    alu_src_b = 2'b01;  // immediate
                end
                else if (is_auipc) begin
                    alu_src_a = 2'b01;  // PC
                    alu_src_b = 2'b01;  // immediate
                end

                // Handle PC updates for branches and jumps
                if ((is_branch && take_branch) || is_jal || is_jalr) begin
                    pc_write = 1'b1;  // Update PC for these instructions
                    
                    if (is_jal || is_jalr)
                        wb_sel = 2'b10;  // PC+4 for link register
                end
            end

            MEM_ACCESS: begin
                if (is_load)
                    mem_read = 1'b1;   // Read from memory
                else if (is_store) begin
                    mem_write = 1'b1;  // Write to memory
                    pc_write = 1'b1;   // Update PC after store
                end
            end 

            WRITEBACK: begin
                // Handle register write-back
                if (!is_store && !is_branch) begin
                    reg_write = 1'b1;  // Enable register write
                    
                    if (is_load)
                        wb_sel = 2'b01;  // Memory data
                    else if (is_jal || is_jalr)
                        wb_sel = 2'b10;  // PC+4 (already set in EXECUTE)
                    else
                        wb_sel = 2'b00;  // ALU result
                end
                
                // Update PC for next instruction if not already updated
                if (!is_branch && !is_jal && !is_jalr && !is_store)
                    pc_write = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule