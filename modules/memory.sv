// RV32I memory module
//
// Implements 8kB of actual memory in the address range of 0x00000000 to
// 0x00001FFF, which can be written to or read from in words (4 bytes), 
// half words (2 bytes), or single bytes. Word accesses are aligned to four-byte 
// boundaries, and half-word access are aligned to two-byte boundaries.
// Half-word and sigle-byte reads are either sign extended or zero extended to 
// 32 bits, depending on the msb of funct3. The value of funct3 should be 3'b010 
// when fetching instructions as it is during execution of lw / sw instructions. 
// Addresses outside of the physical address space are read as 32'd0. The memory 
// can be initialized by specifying via the INIT_FILE parameter the name of a 
// text file containing 2,048 lines of 32-bit hex values. If no file name is 
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

    // Declare memory array for 8kB of actual memory
    logic [31:0] memory [0:2047];

    // Declare variables to save the two LSBs of the read address and funct3
    logic read_address0;
    logic read_address1;
    logic read_word;
    logic read_half;
    logic read_unsigned;

    // Declare variables to make iverilog stop yelling at us
    logic [15:0] read_value10;
    logic [15:0] read_value32;
    logic [7:0] read_value0;
    logic [7:0] read_value1;
    logic [7:0] read_value2;
    logic [7:0] read_value3;
    logic sign_bit0;
    logic sign_bit1;
    logic sign_bit2;
    logic sign_bit3;

    int i;

    // Initialize memory array
    initial begin
        if (INIT_FILE) begin
            $readmemh(INIT_FILE, memory);
        end
        else begin
            for (i = 0; i < 2048; i++) begin
                memory[i] = 32'd0;
            end
        end
    end

    // Handle memory reads
    always_ff @(posedge clk) begin
        read_address1 <= read_address[1];
        read_address0 <= read_address[0];
        read_word <= funct3[1];
        read_half <= funct3[0];
        read_unsigned <= funct3[2];

        if (read_address[31:13] == 19'd0) begin
            read_value <= memory[read_address[12:2]];
        end
        else if (read_address[31:13] == 19'h7FFFF) begin
            case(read_address[12:2])
                11'h7FF:
                    read_value <= leds;
                11'h7FE:
                    read_value <= millis;
                11'h7FD:
                    read_value <= micros;
                default:
                    read_value <= 32'd0;
            endcase
        end
        else begin
            read_value <= 32'd0;
        end
    end

    assign read_value10 = read_value[15:0];
    assign read_value32 = read_value[31:16];
    assign read_value0 = read_value[7:0];
    assign read_value1 = read_value[15:8];
    assign read_value2 = read_value[23:16];
    assign read_value3 = read_value[31:24];
    assign sign_bit0 = read_value[7];
    assign sign_bit1 = read_value[15];
    assign sign_bit2 = read_value[23];
    assign sign_bit3 = read_value[31];

    always_comb begin
        if (read_word) begin
            read_data = read_value;
        end
        else if (read_half && !read_unsigned) begin
            read_data = read_address1 ? {{16{sign_bit3}}, read_value32} : {{16{sign_bit1}}, read_value10};
        end
        else if (read_half && read_unsigned) begin
            read_data = read_address1 ? {16'd0, read_value32} : {16'd0, read_value10};
        end
        else if (!read_half && !read_unsigned) begin
            case ({read_address1, read_address0})
                2'b00:
                    read_data = {{24{sign_bit0}}, read_value0};
                2'b01:
                    read_data = {{24{sign_bit1}}, read_value1};
                2'b10:
                    read_data = {{24{sign_bit2}}, read_value2};
                2'b11:
                    read_data = {{24{sign_bit3}}, read_value3};
            endcase
        end
        else if (!read_half && read_unsigned) begin
            case ({read_address1, read_address0})
                2'b00:
                    read_data = {24'd0, read_value0};
                2'b01:
                    read_data = {24'd0, read_value1};
                2'b10:
                    read_data = {24'd0, read_value2};
                2'b11:
                    read_data = {24'd0, read_value3};
            endcase
        end
        else begin
            read_data = read_value;
        end
    end

    // Handle memory writes
    always_ff @(posedge clk) begin
        if (write_mem) begin
            if (write_address[31:13] == 19'd0) begin
                if (funct3[1]) begin
                    memory[write_address[12:2]] <= write_data;
                end
                else if (funct3[0]) begin
                    if (write_address[1])
                        memory[write_address[12:2]][31:16] <= write_data[15:0];
                    else
                        memory[write_address[12:2]][15:0] <= write_data[15:0];
                end
                else begin
                    case (write_address[1:0])
                        2'b00:
                            memory[write_address[12:2]][7:0] <= write_data[7:0];
                        2'b01:
                            memory[write_address[12:2]][15:8] <= write_data[7:0];
                        2'b10:
                            memory[write_address[12:2]][23:16] <= write_data[7:0];
                        2'b11:
                            memory[write_address[12:2]][31:24] <= write_data[7:0];
                    endcase
                end
            end
            else if (write_address[31:2] == 30'h3FFFFFFF) begin
                if (funct3[1]) begin
                    leds <= write_data;
                end
                else if (funct3[0]) begin
                    if (write_address[1])
                        leds[31:16] <= write_data[15:0];
                    else
                        leds[15:0] <= write_data[15:0];
                end
                else begin
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
                end
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