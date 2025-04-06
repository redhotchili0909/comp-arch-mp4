// RV32I memory module
//
// Implements 16kB of actual memory in the address range of 0x00000000 to
// 0x00003FFF, which can be written to or read from in words (4 bytes), 
// half words (2 bytes), or single bytes. Word accesses are aligned to four-byte 
// boundaries, and half-word access are aligned to two-byte boundaries.
// Half-word and sigle-byte reads are either sign extended or zero extended to 
// 32 bits, depending on the msb of funct3. The value of funct3 should be 3'b010 
// when fetching instructions as it is during execution of lw / sw instructions. 
// Addresses outside of the physical address space are read as 32'd0. The memory 
// can be initialized by specifying via the INIT_FILE parameter the name of a 
// text file containing 4,096 lines of 32-bit hex values. If no file name is 
// specified, the memory is initialized to all 0s.
//
// The memory module also implements some memory-mapped peripherals: 8-bit PWM 
// generators for each of the user LED (0xFFFFFFFF, R/W), RED (0xFFFFFFFE, R/W), 
// GREEN (0xFFFFFFFD, R/W), and BLUE (0xFFFFFFFC, R/W), a running timer that 
// counts the number of milliseconds (mod 2^32) since the processor 
// started (0xFFFFFFF8, R), and a running timer that counts the number of 
// microseconds (mod 2^32) since the processor started (0xFFFFFFF4, R).

module memory #(
    parameter INIT_FILE = ""
)(
    input logic     clk, 
    input logic     write_mem, 
    input logic     [2:0] funct3,   // funct3 should be 3'b010 when fetching instructions as it is during execution of lw / sw instructions
    input logic     [31:0] write_address, 
    input logic     [31:0] write_data, 
    input logic     [31:0] read_address, 
    output logic    [31:0] read_data, 
    output logic    led,            // Active-high PWM output for user LED
    output logic    red,            // Active-high PWM output for red LED
    output logic    green,          // Active-high PWM output for green LED
    output logic    blue            // Active-high PWM output for blue LED
);

    logic [31:0] read_value = 32'd0;

    // Declare variables associated with memory-mapped peripherals
    logic [31:0] leds = 32'd0;      // Address 0xFFFFFFFC, R/W, four 8-bit PWM duty-cycle values for the user LED and the RGB LEDs
    logic [31:0] millis = 32'd0;    // Address 0xFFFFFFF8, R, count of milliseconds since processor started (mod 2^32)
    logic [31:0] micros = 32'd0;    // Address 0xFFFFFFF4, R, count of microseconds since processor started (mod 2^32)

    logic [7:0] pwm_counter = 8'd0;
    logic [13:0] millis_counter = 14'd0;
    logic [3:0] micros_counter = 4'd0;

    // Declare memory array for 16kB of actual memory
    logic [31:0] memory [0:4095];

    int i;

    // Initialize memory array
    initial begin
        if (INIT_FILE) begin
            $readmemh(INIT_FILE, memory);
        end
        else begin
            for (i = 0; i < 4096; i++) begin
                memory[i] = 32'd0;
            end
        end
    end

    // Handle memory reads
    always_ff @(posedge clk) begin
        if (read_address[31:14] == 18'd0) begin
            read_value <= memory[read_address[13:2]];
        end
        else if (read_address[31:14] == 18'h3FFFF) begin
            case(read_address[13:2])
                12'hFFF:
                    read_value <= leds;
                12'hFFE:
                    read_value <= millis;
                12'hFFD:
                    read_value <= micros;
                default:
                    read_value <= 32'd0;
            endcase
        end
        else begin
            read_value <= 32'd0;
        end
    end

    always_comb begin
        read_data = read_value;
        case (funct3)
            3'b000: begin
                case (read_address[1:0]):
                    2'b00:
                        read_data = {24{read_value[7]}, read_value[7:0]};
                    2'b01:
                        read_data = {24{read_value[15]}, read_value[15:8]};
                    2'b10:
                        read_data = {24{read_value[23]}, read_value[23:16]};
                    2'b11:
                        read_data = {24{read_value[31]}, read_value[31:24]};
                endcase
            end
            3'b001:
                read_data = read_address[1] ? {16{read_value[31]}, read_value[31:16]} : {16{read_value[15]}, read_value[15:0]};
            3'b010:
                read_data = read_value;
            3'b100: begin
                case (read_address[1:0]):
                    2'b00:
                        read_data = {24'd0, read_value[7:0]};
                    2'b01:
                        read_data = {24'd0, read_value[15:8]};
                    2'b10:
                        read_data = {24'd0, read_value[23:16]};
                    2'b11:
                        read_data = {24'd0, read_value[31:24]};
                endcase
            end
            3'b101:
                read_data = read_address[1] ? {16'd0, read_value[31:16]} : {16'd0, read_value[15:0]};
        endcase
    end

    // Handle memory writes
    always_ff @(posedge clk) begin
        if (write_enable) begin
            if (write_address[31:14] == 18'd0) begin
                case (funct3)
                    3'b000:
                        case (write_address[1:0])
                            2'b00:
                                memory[write_address[13:2]][7:0] <= write_data[7:0];
                            2'b01:
                                memory[write_address[13:2]][15:8] <= write_data[7:0];
                            2'b10:
                                memory[write_address[13:2]][23:16] <= write_data[7:0];
                            2'b11:
                                memory[write_address[13:2]][31:24] <= write_data[7:0];
                        endcase
                    3'b001:
                        if (write_address[1])
                            memory[write_address[13:2]][31:16] <= write_data[15:0];
                        else
                            memory[write_address[13:2]][15:0] <= write_data[15:0];
                    3'b010:
                        memory[write_address[13:2]] <= write_data;
                endcase
            end
            else if (write_address[31:2] == 30'h3FFFFFF) begin
                case (funct3)
                    3'b000:
                        case (write_address[1:0])
                            2'b00:
                                leds[7:0] <= write_data[7:0];
                            2'b01:
                                leds[15:8] <= write_data[7:0];
                            2'b10:
                                leds[23:16] <= write_data[7:0];
                            2'b11:
                                leds[31:24] <= write_data[7:0];
                        endcase
                    3'b001:
                        if (write_address[1])
                            leds[31:16] <= write_data[15:0];
                        else
                            leds[15:0] <= write_data[15:0];
                    3'b010:
                        leds <= write_data;
                endcase
            end
        end
    end

    // Implement PWM control for LED / RGB outputs
    always_ff @(posedge clk) begin
        pwm_counter <= pwm_counter + 1;
    end

    assign led = (pwm_counter < leds[31:24]);
    assign red = (pwm_counter < leds[23:16]);
    assign green = (pwm_counter < leds[15:8]);
    assign blue = (pwm_counter < leds[7:0]);

    // Implement millis counter
    always_ff @(posedge clk) begin
        if (millis_counter == 11999) begin
            millis_counter <= 14'd0;
            millis <= millis + 1;
        end
        else begin
            millis_counter <= millis_counter + 1;
        end
    end

    // Implement micros counter
    always_ff @(posedge clk) begin
        if (micros_counter == 11) begin
            micros_counter <= 4'd0;
            micros <= micros + 1;
        end
        else begin
            micros_counter <= micros_counter + 1;
        end
    end

endmodule
