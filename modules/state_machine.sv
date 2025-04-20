typedef enum logic [1:0] {
    IS_STORE,
    IS_LOAD,
    IS_BRANCH,
    IS_JAL
} action_t;

module state_machine(
    input logic clk,
    input action_t action_type,
    input logic [31:0] memory_rd,
    input logic [31:0] pc_out,
    input logic [31:0] immediate,
    input logic [31:0] rs1_data,
    input logic [2:0] func3,
    output logic reg_wen,
    output logic memory_wen,
    output logic [31:0] memory_ra,
    output logic [2:0] memory_func3,
    output logic [31:0] pc_in,
    output logic [31:0] instruction
);

    typedef enum logic [1:0] {
        FETCH,
        EXECUTE,
        MEMORY
    } state_t;

    state_t state;

    initial begin
        pc_in = 32'b0;
        state = MEMORY;
        instruction = 32'b0;
    end

    assign reg_wen = !(action_type == IS_BRANCH | action_type == IS_STORE) & (state != FETCH);
    assign memory_func3 = ((action_type == IS_LOAD | action_type == IS_STORE) & state != MEMORY) ? func3 : 3'b010;
    assign memory_wen = action_type == IS_STORE & state == EXECUTE;

    always_comb begin
        if (state == MEMORY) begin  
            memory_ra = pc_in; // read current instruction
        end else begin
            if (action_type == IS_LOAD) begin
                memory_ra = rs1_data + immediate; // load data from memory
            end else begin
                memory_ra = pc_out; // read next instruction
            end
        end
    end

    always_ff @(posedge clk) begin
        case (state)
            FETCH: begin
                if (action_type == IS_JAL) begin
                    pc_in <= pc_out;
                end
                state <= EXECUTE;
                instruction <= memory_rd;
            end
            EXECUTE: begin
                if (action_type != IS_JAL) begin
                    pc_in <= pc_out;
                end
                if (action_type == IS_LOAD | action_type == IS_STORE) begin
                    state <= MEMORY;
                end else begin
                    state <= FETCH;
                end
            end
            MEMORY: begin // MEMORY
                state <= FETCH;
            end
        endcase
    end

endmodule
