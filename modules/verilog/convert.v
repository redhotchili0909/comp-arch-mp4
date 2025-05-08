module alu (
	alu_a,
	alu_b,
	alu_op,
	alu_result
);
	reg _sv2v_0;
	input wire [31:0] alu_a;
	input wire [31:0] alu_b;
	input wire [4:0] alu_op;
	output reg [31:0] alu_result;
	localparam ALU_ADD = 5'b00000;
	localparam ALU_SUB = 5'b00001;
	localparam ALU_SLL = 5'b00010;
	localparam ALU_SLT = 5'b00011;
	localparam ALU_SLTU = 5'b00100;
	localparam ALU_XOR = 5'b00101;
	localparam ALU_SRL = 5'b00110;
	localparam ALU_SRA = 5'b00111;
	localparam ALU_OR = 5'b01000;
	localparam ALU_AND = 5'b01001;
	localparam ALU_BEQ = 5'b01010;
	localparam ALU_LUI = 5'b01011;
	localparam ALU_AUIPC = 5'b01100;
	localparam ALU_BNE = 5'b01101;
	localparam ALU_BLT = 5'b01110;
	localparam ALU_BGE = 5'b01111;
	localparam ALU_BLTU = 5'b10000;
	localparam ALU_BGEU = 5'b10001;
	reg [31:0] add_sub_result;
	wire [31:0] shift_amount;
	wire signed_lt;
	wire unsigned_lt;
	wire equal;
	assign shift_amount = {27'b000000000000000000000000000, alu_b[4:0]};
	assign equal = alu_a == alu_b;
	assign signed_lt = $signed(alu_a) < $signed(alu_b);
	assign unsigned_lt = alu_a < alu_b;
	always @(*) begin
		if (_sv2v_0)
			;
		if (alu_op == ALU_SUB)
			add_sub_result = $signed(alu_a) - $signed(alu_b);
		else
			add_sub_result = $signed(alu_a) + $signed(alu_b);
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (alu_op)
			ALU_ADD, ALU_SUB: alu_result = add_sub_result;
			ALU_SLL: alu_result = alu_a << shift_amount;
			ALU_SLT: alu_result = {31'b0000000000000000000000000000000, signed_lt};
			ALU_SLTU: alu_result = {31'b0000000000000000000000000000000, unsigned_lt};
			ALU_XOR: alu_result = alu_a ^ alu_b;
			ALU_SRL: alu_result = alu_a >> shift_amount;
			ALU_SRA: alu_result = $signed(alu_a) >>> shift_amount;
			ALU_OR: alu_result = alu_a | alu_b;
			ALU_AND: alu_result = alu_a & alu_b;
			ALU_AUIPC: alu_result = add_sub_result;
			ALU_BEQ: alu_result = {31'b0000000000000000000000000000000, equal};
			ALU_BNE: alu_result = {31'b0000000000000000000000000000000, !equal};
			ALU_BLT: alu_result = {31'b0000000000000000000000000000000, signed_lt};
			ALU_BGE: alu_result = {31'b0000000000000000000000000000000, !signed_lt};
			ALU_BLTU: alu_result = {31'b0000000000000000000000000000000, unsigned_lt};
			ALU_BGEU: alu_result = {31'b0000000000000000000000000000000, !unsigned_lt};
			default: alu_result = 32'b00000000000000000000000000000000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module control (
	opcode,
	func3,
	func7,
	pc_source,
	rd_source,
	alu_source,
	alu_op,
	instruction_type
);
	reg _sv2v_0;
	input wire [6:0] opcode;
	input wire [2:0] func3;
	input wire [6:0] func7;
	output reg [1:0] pc_source;
	output reg [1:0] rd_source;
	output reg [1:0] alu_source;
	output reg [4:0] alu_op;
	output reg [2:0] instruction_type;
	localparam [6:0] OP_LUI = 7'b0110111;
	localparam [6:0] OP_AUIPC = 7'b0010111;
	localparam [6:0] OP_JAL = 7'b1101111;
	localparam [6:0] OP_JALR = 7'b1100111;
	localparam [6:0] OP_BRANCH = 7'b1100011;
	localparam [6:0] OP_LOAD = 7'b0000011;
	localparam [6:0] OP_STORE = 7'b0100011;
	localparam [6:0] OP_REG = 7'b0110011;
	localparam [6:0] OP_IMM = 7'b0010011;
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			OP_LUI, OP_AUIPC: instruction_type = 3'd1;
			OP_JAL: instruction_type = 3'd5;
			OP_JALR, OP_LOAD, OP_IMM: instruction_type = 3'd0;
			OP_BRANCH: instruction_type = 3'd4;
			OP_REG: instruction_type = 3'd3;
			OP_STORE: instruction_type = 3'd2;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			OP_JAL: pc_source = 2'b01;
			OP_JALR: pc_source = 2'b00;
			OP_BRANCH: pc_source = 2'b10;
			default: pc_source = 2'b11;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			OP_REG, OP_IMM, OP_AUIPC: rd_source = 2'b00;
			OP_JAL, OP_JALR: rd_source = 2'b01;
			OP_LOAD: rd_source = 2'b10;
			OP_LUI: rd_source = 2'b11;
			default: rd_source = 2'b00;
		endcase
	end
	localparam ALU_ADD = 5'b00000;
	localparam ALU_SUB = 5'b00001;
	localparam ALU_SLL = 5'b00010;
	localparam ALU_SLT = 5'b00011;
	localparam ALU_SLTU = 5'b00100;
	localparam ALU_XOR = 5'b00101;
	localparam ALU_SRL = 5'b00110;
	localparam ALU_SRA = 5'b00111;
	localparam ALU_OR = 5'b01000;
	localparam ALU_AND = 5'b01001;
	localparam ALU_BEQ = 5'b01010;
	localparam ALU_LUI = 5'b01011;
	localparam ALU_AUIPC = 5'b01100;
	localparam ALU_BNE = 5'b01101;
	localparam ALU_BLT = 5'b01110;
	localparam ALU_BGE = 5'b01111;
	localparam ALU_BLTU = 5'b10000;
	localparam ALU_BGEU = 5'b10001;
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			OP_REG: begin
				alu_source = 2'b00;
				(* full_case, parallel_case *)
				case (func3)
					3'b000: alu_op = (func7[5] ? ALU_SUB : ALU_ADD);
					3'b001: alu_op = ALU_SLL;
					3'b010: alu_op = ALU_SLT;
					3'b011: alu_op = ALU_SLTU;
					3'b100: alu_op = ALU_XOR;
					3'b101: alu_op = (func7[5] ? ALU_SRA : ALU_SRL);
					3'b110: alu_op = ALU_OR;
					3'b111: alu_op = ALU_AND;
				endcase
			end
			OP_IMM: begin
				alu_source = 2'b01;
				(* full_case, parallel_case *)
				case (func3)
					3'b000: alu_op = ALU_ADD;
					3'b001: alu_op = ALU_SLL;
					3'b010: alu_op = ALU_SLT;
					3'b011: alu_op = ALU_SLTU;
					3'b100: alu_op = ALU_XOR;
					3'b101: alu_op = (func7[5] ? ALU_SRA : ALU_SRL);
					3'b110: alu_op = ALU_OR;
					3'b111: alu_op = ALU_AND;
				endcase
			end
			OP_BRANCH: begin
				alu_source = 2'b00;
				(* full_case, parallel_case *)
				case (func3)
					3'b000: alu_op = ALU_BEQ;
					3'b001: alu_op = ALU_BNE;
					3'b100: alu_op = ALU_BLT;
					3'b101: alu_op = ALU_BGE;
					3'b110: alu_op = ALU_BLTU;
					3'b111: alu_op = ALU_BGEU;
				endcase
			end
			OP_AUIPC: begin
				alu_source = 2'b10;
				alu_op = ALU_AUIPC;
			end
			OP_JALR: begin
				alu_source = 2'b01;
				alu_op = ALU_ADD;
			end
			default: begin
				alu_source = 2'b00;
				alu_op = ALU_ADD;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module immed_gen (
	instruction,
	immediate
);
	reg _sv2v_0;
	input wire [31:0] instruction;
	output reg [31:0] immediate;
	wire [6:0] opcode;
	assign opcode = instruction[6:0];
	localparam [6:0] OP_AUIPC = 7'b0010111;
	localparam [6:0] OP_BRANCH = 7'b1100011;
	localparam [6:0] OP_IMM = 7'b0010011;
	localparam [6:0] OP_JAL = 7'b1101111;
	localparam [6:0] OP_JALR = 7'b1100111;
	localparam [6:0] OP_LOAD = 7'b0000011;
	localparam [6:0] OP_LUI = 7'b0110111;
	localparam [6:0] OP_STORE = 7'b0100011;
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			OP_LOAD, OP_JALR, OP_IMM: immediate = {{20 {instruction[31]}}, instruction[31:20]};
			OP_STORE: immediate = {{20 {instruction[31]}}, instruction[31:25], instruction[11:7]};
			OP_BRANCH: immediate = {{20 {instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			OP_JAL: immediate = {{12 {instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			OP_AUIPC, OP_LUI: immediate = {instruction[31:12], 12'b000000000000};
			default: immediate = 32'b00000000000000000000000000000000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module program_counter (
	pc_source,
	rs1_data,
	immediate,
	alu_result,
	pc_in,
	pc_out
);
	reg _sv2v_0;
	input wire [1:0] pc_source;
	input wire [31:0] rs1_data;
	input wire [31:0] immediate;
	input wire [31:0] alu_result;
	input wire [31:0] pc_in;
	output reg [31:0] pc_out;
	wire [31:0] pc_increment;
	wire [31:0] pc_immed;
	wire [31:0] pc_rs1;
	assign pc_increment = pc_in + 4;
	assign pc_immed = pc_in + $signed(immediate);
	assign pc_rs1 = rs1_data + $signed(immediate);
	always @(*) begin
		if (_sv2v_0)
			;
		case (pc_source)
			2'b00: pc_out = pc_rs1;
			2'b01: pc_out = pc_immed;
			2'b10: pc_out = (alu_result == 32'b00000000000000000000000000000001 ? pc_immed : pc_increment);
			default: pc_out = pc_increment;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module register_file (
	clk,
	rs1,
	rs2,
	rd,
	rdv,
	reg_wen,
	rs1_data,
	rs2_data
);
	reg _sv2v_0;
	input wire clk;
	input wire [4:0] rs1;
	input wire [4:0] rs2;
	input wire [4:0] rd;
	input wire [31:0] rdv;
	input wire reg_wen;
	output reg [31:0] rs1_data;
	output reg [31:0] rs2_data;
	reg [31:0] registers [0:31];
	reg [4:0] last_rd;
	reg [31:0] last_rdv;
	reg last_wen;
	initial begin
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				registers[i] = 32'b00000000000000000000000000000000;
		end
		last_rd = 5'b00000;
		last_rdv = 32'b00000000000000000000000000000000;
		last_wen = 1'b0;
	end
	always @(posedge clk) begin
		if (reg_wen && (rd != 5'b00000))
			registers[rd] <= rdv;
		last_rd <= rd;
		last_rdv <= rdv;
		last_wen <= reg_wen;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		rs1_data = (rs1 == 5'd0 ? 32'd0 : ((rs1 == last_rd) && last_wen ? last_rdv : registers[rs1]));
		rs2_data = (rs2 == 5'd0 ? 32'd0 : ((rs2 == last_rd) && last_wen ? last_rdv : registers[rs2]));
	end
	initial _sv2v_0 = 0;
endmodule
module state_machine (
	clk,
	action_type,
	memory_rd,
	pc_out,
	immediate,
	rs1_data,
	func3,
	reg_wen,
	memory_wen,
	memory_ra,
	memory_func3,
	pc_in,
	instruction
);
	reg _sv2v_0;
	input wire clk;
	input wire [2:0] action_type;
	input wire [31:0] memory_rd;
	input wire [31:0] pc_out;
	input wire [31:0] immediate;
	input wire [31:0] rs1_data;
	input wire [2:0] func3;
	output wire reg_wen;
	output wire memory_wen;
	output reg [31:0] memory_ra;
	output wire [2:0] memory_func3;
	output reg [31:0] pc_in;
	output reg [31:0] instruction;
	reg [1:0] state;
	initial begin
		pc_in = 32'b00000000000000000000000000000000;
		state = 2'b10;
		instruction = 32'b00000000000000000000000000000000;
	end
	assign reg_wen = !((action_type == 3'd2) || (action_type == 3'd0)) & ((state == 2'b01) || ((state == 2'b10) && (action_type != 3'd4)));
	assign memory_func3 = (((action_type == 3'd1) || (action_type == 3'd0)) & (state == 2'b01) ? func3 : 3'b010);
	assign memory_wen = (action_type == 3'd0) && (state == 2'b01);
	always @(*) begin
		if (_sv2v_0)
			;
		memory_ra = 32'b00000000000000000000000000000000;
		if (state == 2'b10)
			memory_ra = pc_in;
		else if (action_type == 3'd1)
			memory_ra = rs1_data + immediate;
		else
			memory_ra = pc_out;
	end
	always @(posedge clk)
		case (state)
			2'b00: begin
				if (action_type == 3'd3)
					pc_in <= pc_out;
				state <= 2'b01;
				instruction <= memory_rd;
			end
			2'b01: begin
				if (action_type != 3'd3)
					pc_in <= pc_out;
				if ((action_type == 3'd1) || (action_type == 3'd0))
					state <= 2'b10;
				else
					state <= 2'b00;
			end
			2'b10: state <= 2'b00;
		endcase
	initial _sv2v_0 = 0;
endmodule
module risc_v (
	clk,
	memory_wen,
	memory_ra,
	memory_wa,
	memory_rd,
	memory_wd,
	memory_func3
);
	reg _sv2v_0;
	input wire clk;
	output wire memory_wen;
	output wire [31:0] memory_ra;
	output wire [31:0] memory_wa;
	input wire [31:0] memory_rd;
	output wire [31:0] memory_wd;
	output wire [2:0] memory_func3;
	wire [1:0] rd_source;
	wire [1:0] pc_source;
	wire [1:0] alu_source;
	wire [4:0] alu_op;
	wire [2:0] instruction_type;
	reg [2:0] action_type;
	localparam [6:0] OP_LUI = 7'b0110111;
	localparam [6:0] OP_AUIPC = 7'b0010111;
	localparam [6:0] OP_JAL = 7'b1101111;
	localparam [6:0] OP_JALR = 7'b1100111;
	localparam [6:0] OP_BRANCH = 7'b1100011;
	localparam [6:0] OP_LOAD = 7'b0000011;
	localparam [6:0] OP_STORE = 7'b0100011;
	localparam [6:0] OP_REG = 7'b0110011;
	localparam [6:0] OP_IMM = 7'b0010011;
	wire [31:0] instruction;
	wire [6:0] opcode;
	wire [2:0] func3;
	wire [6:0] func7;
	assign opcode = instruction[6:0];
	assign func3 = instruction[14:12];
	assign func7 = instruction[31:25];
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			OP_STORE: action_type = 3'd0;
			OP_LOAD: action_type = 3'd1;
			OP_BRANCH: action_type = 3'd2;
			OP_JAL: action_type = 3'd3;
			OP_LUI, OP_AUIPC: action_type = 3'd4;
			OP_REG, OP_IMM: action_type = 3'd4;
			default: action_type = 3'd1;
		endcase
	end
	control u_control(
		.opcode(opcode),
		.func3(func3),
		.func7(func7),
		.alu_op(alu_op),
		.alu_source(alu_source),
		.pc_source(pc_source),
		.rd_source(rd_source),
		.instruction_type(instruction_type)
	);
	wire reg_wen;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	reg [31:0] rdv;
	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign rd = instruction[11:7];
	register_file u_register_file(
		.clk(clk),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data),
		.rdv(rdv),
		.reg_wen(reg_wen)
	);
	wire [31:0] immediate;
	immed_gen u_immed_gen(
		.instruction(instruction),
		.immediate(immediate)
	);
	wire [31:0] pc_in;
	wire [31:0] pc_out;
	wire [31:0] alu_result;
	program_counter u_program_counter(
		.pc_source(pc_source),
		.rs1_data(rs1_data),
		.immediate(immediate),
		.alu_result(alu_result),
		.pc_in(pc_in),
		.pc_out(pc_out)
	);
	reg [31:0] alu_a;
	reg [31:0] alu_b;
	always @(*) begin
		if (_sv2v_0)
			;
		case (alu_source)
			2'b00: begin
				alu_a = rs1_data;
				alu_b = rs2_data;
			end
			2'b01: begin
				alu_a = rs1_data;
				alu_b = immediate;
			end
			2'b10: begin
				alu_a = pc_in;
				alu_b = immediate;
			end
			default: begin
				alu_a = rs1_data;
				alu_b = rs2_data;
			end
		endcase
	end
	alu u_alu(
		.alu_a(alu_a),
		.alu_b(alu_b),
		.alu_op(alu_op),
		.alu_result(alu_result)
	);
	state_machine u_state_machine(
		.clk(clk),
		.action_type(action_type),
		.memory_rd(memory_rd),
		.pc_out(pc_out),
		.immediate(immediate),
		.rs1_data(rs1_data),
		.func3(func3),
		.reg_wen(reg_wen),
		.memory_wen(memory_wen),
		.memory_ra(memory_ra),
		.memory_func3(memory_func3),
		.pc_in(pc_in),
		.instruction(instruction)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		case (rd_source)
			2'b00: rdv = alu_result;
			2'b01: rdv = pc_out + 4;
			2'b10: rdv = memory_rd;
			2'b11: rdv = immediate;
			default: rdv = 32'b00000000000000000000000000000000;
		endcase
	end
	assign memory_wa = rs1_data + immediate;
	assign memory_wd = rs2_data;
	initial _sv2v_0 = 0;
endmodule
module memory (
	clk,
	write_mem,
	funct3,
	write_address,
	write_data,
	read_address,
	read_data,
	led,
	red,
	green,
	blue
);
	reg _sv2v_0;
	parameter INIT_FILE = "";
	input wire clk;
	input wire write_mem;
	input wire [2:0] funct3;
	input wire [31:0] write_address;
	input wire [31:0] write_data;
	input wire [31:0] read_address;
	output reg [31:0] read_data;
	output wire led;
	output wire red;
	output wire green;
	output wire blue;
	reg [31:0] read_value = 32'd0;
	reg [31:0] leds = 32'd0;
	reg [31:0] millis = 32'd0;
	reg [31:0] micros = 32'd0;
	reg [7:0] pwm_counter = 8'd0;
	reg [13:0] millis_counter = 14'd0;
	reg [3:0] micros_counter = 4'd0;
	reg read_address0;
	reg read_address1;
	reg read_word;
	reg read_half;
	reg read_unsigned;
	wire [15:0] read_value10;
	wire [15:0] read_value32;
	wire [7:0] read_value0;
	wire [7:0] read_value1;
	wire [7:0] read_value2;
	wire [7:0] read_value3;
	wire sign_bit0;
	wire sign_bit1;
	wire sign_bit2;
	wire sign_bit3;
	wire [31:0] read_val;
	wire write_address0;
	wire write_address1;
	wire write_word;
	wire write_half;
	wire [7:0] write_data0;
	wire [7:0] write_data1;
	wire [7:0] write_data2;
	wire [7:0] write_data3;
	wire mem_write_enable;
	reg mem_write_enable0;
	reg mem_write_enable1;
	reg mem_write_enable2;
	reg mem_write_enable3;
	reg [7:0] mem_write_data0;
	reg [7:0] mem_write_data1;
	reg [7:0] mem_write_data2;
	reg [7:0] mem_write_data3;
	wire mem_read_enable;
	wire [7:0] mem_read_data0;
	wire [7:0] mem_read_data1;
	wire [7:0] mem_read_data2;
	wire [7:0] mem_read_data3;
	memory_array #(.INIT_FILE((INIT_FILE != "" ? {INIT_FILE, "0.txt"} : ""))) mem0(
		.clk(clk),
		.write_enable(mem_write_enable0),
		.write_address(write_address[12:2]),
		.write_data(mem_write_data0),
		.read_enable(mem_read_enable),
		.read_address(read_address[12:2]),
		.read_data(mem_read_data0)
	);
	memory_array #(.INIT_FILE((INIT_FILE != "" ? {INIT_FILE, "1.txt"} : ""))) mem1(
		.clk(clk),
		.write_enable(mem_write_enable1),
		.write_address(write_address[12:2]),
		.write_data(mem_write_data1),
		.read_enable(mem_read_enable),
		.read_address(read_address[12:2]),
		.read_data(mem_read_data1)
	);
	memory_array #(.INIT_FILE((INIT_FILE != "" ? {INIT_FILE, "2.txt"} : ""))) mem2(
		.clk(clk),
		.write_enable(mem_write_enable2),
		.write_address(write_address[12:2]),
		.write_data(mem_write_data2),
		.read_enable(mem_read_enable),
		.read_address(read_address[12:2]),
		.read_data(mem_read_data2)
	);
	memory_array #(.INIT_FILE((INIT_FILE != "" ? {INIT_FILE, "3.txt"} : ""))) mem3(
		.clk(clk),
		.write_enable(mem_write_enable3),
		.write_address(write_address[12:2]),
		.write_data(mem_write_data3),
		.read_enable(mem_read_enable),
		.read_address(read_address[12:2]),
		.read_data(mem_read_data3)
	);
	assign mem_read_enable = read_address[31:13] == 19'd0;
	assign read_val = (mem_read_enable ? {mem_read_data3, mem_read_data2, mem_read_data1, mem_read_data0} : read_value);
	always @(posedge clk) begin
		read_address1 <= read_address[1];
		read_address0 <= read_address[0];
		read_word <= funct3[1];
		read_half <= funct3[0];
		read_unsigned <= funct3[2];
		if (read_address[31:13] == 19'h7ffff)
			case (read_address[12:2])
				11'h7ff: read_value <= leds;
				11'h7fe: read_value <= millis;
				11'h7fd: read_value <= micros;
				default: read_value <= 32'd0;
			endcase
		else
			read_value <= 32'd0;
	end
	assign read_value10 = read_val[15:0];
	assign read_value32 = read_val[31:16];
	assign read_value0 = read_val[7:0];
	assign read_value1 = read_val[15:8];
	assign read_value2 = read_val[23:16];
	assign read_value3 = read_val[31:24];
	assign sign_bit0 = read_val[7];
	assign sign_bit1 = read_val[15];
	assign sign_bit2 = read_val[23];
	assign sign_bit3 = read_val[31];
	always @(*) begin
		if (_sv2v_0)
			;
		if (read_word)
			read_data = read_val;
		else if (read_half && !read_unsigned)
			read_data = (read_address1 ? {{16 {sign_bit3}}, read_value32} : {{16 {sign_bit1}}, read_value10});
		else if (read_half && read_unsigned)
			read_data = (read_address1 ? {16'd0, read_value32} : {16'd0, read_value10});
		else if (!read_half && !read_unsigned)
			case ({read_address1, read_address0})
				2'b00: read_data = {{24 {sign_bit0}}, read_value0};
				2'b01: read_data = {{24 {sign_bit1}}, read_value1};
				2'b10: read_data = {{24 {sign_bit2}}, read_value2};
				2'b11: read_data = {{24 {sign_bit3}}, read_value3};
			endcase
		else
			case ({read_address1, read_address0})
				2'b00: read_data = {24'd0, read_value0};
				2'b01: read_data = {24'd0, read_value1};
				2'b10: read_data = {24'd0, read_value2};
				2'b11: read_data = {24'd0, read_value3};
			endcase
	end
	assign mem_write_enable = (write_address[31:13] == 19'd0) & write_mem;
	assign write_address0 = write_address[0];
	assign write_address1 = write_address[1];
	assign write_word = funct3[1];
	assign write_half = funct3[0];
	assign write_data0 = write_data[7:0];
	assign write_data1 = write_data[15:8];
	assign write_data2 = write_data[23:16];
	assign write_data3 = write_data[31:24];
	always @(*) begin
		if (_sv2v_0)
			;
		if (write_word) begin
			mem_write_enable0 = mem_write_enable;
			mem_write_enable1 = mem_write_enable;
			mem_write_enable2 = mem_write_enable;
			mem_write_enable3 = mem_write_enable;
			mem_write_data0 = write_data0;
			mem_write_data1 = write_data1;
			mem_write_data2 = write_data2;
			mem_write_data3 = write_data3;
		end
		else if (write_half & ~write_address1) begin
			mem_write_enable0 = mem_write_enable;
			mem_write_enable1 = mem_write_enable;
			mem_write_enable2 = 1'b0;
			mem_write_enable3 = 1'b0;
			mem_write_data0 = write_data0;
			mem_write_data1 = write_data1;
			mem_write_data2 = 8'd0;
			mem_write_data3 = 8'd0;
		end
		else if (write_half & write_address1) begin
			mem_write_enable0 = 1'b0;
			mem_write_enable1 = 1'b0;
			mem_write_enable2 = mem_write_enable;
			mem_write_enable3 = mem_write_enable;
			mem_write_data0 = 8'd0;
			mem_write_data1 = 8'd0;
			mem_write_data2 = write_data0;
			mem_write_data3 = write_data1;
		end
		else
			case ({write_address1, write_address0})
				2'b00: begin
					mem_write_enable0 = mem_write_enable;
					mem_write_enable1 = 1'b0;
					mem_write_enable2 = 1'b0;
					mem_write_enable3 = 1'b0;
					mem_write_data0 = write_data0;
					mem_write_data1 = 8'd0;
					mem_write_data2 = 8'd0;
					mem_write_data3 = 8'd0;
				end
				2'b01: begin
					mem_write_enable0 = 1'b0;
					mem_write_enable1 = mem_write_enable;
					mem_write_enable2 = 1'b0;
					mem_write_enable3 = 1'b0;
					mem_write_data0 = 8'd0;
					mem_write_data1 = write_data0;
					mem_write_data2 = 8'd0;
					mem_write_data3 = 8'd0;
				end
				2'b10: begin
					mem_write_enable0 = 1'b0;
					mem_write_enable1 = 1'b0;
					mem_write_enable2 = mem_write_enable;
					mem_write_enable3 = 1'b0;
					mem_write_data0 = 8'd0;
					mem_write_data1 = 8'd0;
					mem_write_data2 = write_data0;
					mem_write_data3 = 8'd0;
				end
				2'b11: begin
					mem_write_enable0 = 1'b0;
					mem_write_enable1 = 1'b0;
					mem_write_enable2 = 1'b0;
					mem_write_enable3 = mem_write_enable;
					mem_write_data0 = 8'd0;
					mem_write_data1 = 8'd0;
					mem_write_data2 = 8'd0;
					mem_write_data3 = write_data0;
				end
			endcase
	end
	always @(posedge clk)
		if (write_mem) begin
			if (write_address[31:2] == 30'h3fffffff) begin
				if (funct3[1])
					leds <= write_data;
				else if (funct3[0]) begin
					if (write_address[1])
						leds[31:16] <= write_data[15:0];
					else
						leds[15:0] <= write_data[15:0];
				end
				else
					case (write_address[1:0])
						2'b00: leds[7:0] <= write_data[7:0];
						2'b01: leds[15:8] <= write_data[7:0];
						2'b10: leds[23:16] <= write_data[7:0];
						2'b11: leds[31:24] <= write_data[7:0];
					endcase
			end
		end
	always @(posedge clk) pwm_counter <= pwm_counter + 1;
	assign led = pwm_counter < leds[31:24];
	assign red = pwm_counter < leds[23:16];
	assign green = pwm_counter < leds[15:8];
	assign blue = pwm_counter < leds[7:0];
	always @(posedge clk)
		if (millis_counter == 11999) begin
			millis_counter <= 14'd0;
			millis <= millis + 1;
		end
		else
			millis_counter <= millis_counter + 1;
	always @(posedge clk)
		if (micros_counter == 11) begin
			micros_counter <= 4'd0;
			micros <= micros + 1;
		end
		else
			micros_counter <= micros_counter + 1;
	initial _sv2v_0 = 0;
endmodule
module memory_array (
	clk,
	write_enable,
	write_address,
	write_data,
	read_enable,
	read_address,
	read_data
);
	parameter INIT_FILE = "";
	input wire clk;
	input wire write_enable;
	input wire [10:0] write_address;
	input wire [7:0] write_data;
	input wire read_enable;
	input wire [10:0] read_address;
	output reg [7:0] read_data;
	reg [7:0] memory [0:2047];
	reg signed [31:0] i;
	initial if (INIT_FILE)
		$readmemh(INIT_FILE, memory);
	else
		for (i = 0; i < 2048; i = i + 1)
			memory[i] <= 8'd0;
	always @(posedge clk)
		if (read_enable)
			read_data <= memory[read_address];
	always @(posedge clk)
		if (write_enable)
			memory[write_address] <= write_data;
endmodule
module top (
	LED,
	RGB_R,
	RGB_B,
	RGB_G
);
	output wire LED;
	output wire RGB_R;
	output wire RGB_B;
	output wire RGB_G;
	wire clk;
	SB_HFOSC #(.CLKHF_DIV("0b11")) hfosc_inst(
		.CLKHFEN(1'b1),
		.CLKHFPU(1'b1),
		.CLKHF(clk)
	);
	wire [31:0] memory_ra;
	wire [31:0] memory_wa;
	wire [31:0] memory_rd;
	wire [31:0] memory_wd;
	wire memory_wen;
	wire [2:0] memory_func3;
	risc_v u_risc_v(
		.clk(clk),
		.memory_wen(memory_wen),
		.memory_ra(memory_ra),
		.memory_wa(memory_wa),
		.memory_rd(memory_rd),
		.memory_wd(memory_wd),
		.memory_func3(memory_func3)
	);
	memory #(.INIT_FILE("set_led")) u_memory(
		.clk(clk),
		.write_mem(memory_wen),
		.funct3(memory_func3),
		.write_address(memory_wa),
		.write_data(memory_wd),
		.read_address(memory_ra),
		.read_data(memory_rd),
		.led(LED),
		.red(RGB_R),
		.green(RGB_G),
		.blue(RGB_B)
	);
endmodule