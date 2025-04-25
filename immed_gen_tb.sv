`timescale 1ns/1ns
`include "modules/immed_gen.sv"

module immed_gen_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;

    immed_gen uut (
        .instruction(instruction),
        .immediate(immediate)
    );

    task test_immed(input [31:0] instr, input [31:0] expected);
        instruction = instr;
        #1; // wait for combinational logic
        if (immediate !== expected) begin
            $display("FAILED: instruction = 0x%08h | expected = 0x%08h | got = 0x%08h", instr, expected, immediate);
        end else begin
            $display("PASSED: instruction = 0x%08h | immediate = 0x%08h", instr, immediate);
        end
    endtask

    initial begin
        $dumpfile("immed_gen_tb.vcd");
        $dumpvars(0, immed_gen_tb);
        $display("Starting Immediate Generator Tests...");

        // I-Type: LW (opcode = 0000011)
        test_immed(32'b000000000001_00000_010_00001_0000011, 32'h00000001);

        // I-Type: SLLI (opcode = 0010011, funct3 = 001)
        test_immed(32'b0000000_00010_00001_001_00001_0010011, 32'h00000002); // shift amount = 2

        // S-Type: SW (opcode = 0100011)
        test_immed(32'b0000001_00010_00001_010_00010_0100011, 32'h00000022);

        // B-Type: BEQ (opcode = 1100011)
        test_immed(32'b000000000010000010000000111100011, 32'h00000802);

        // J-Type: JAL (opcode = 1101111)
        test_immed(32'b11111111111111111111000001101111, 32'hFFFFFFFE);

        // U-Type: LUI (opcode = 0110111)
        test_immed(32'b00010010001101000101_00001_0110111, 32'h12345000);

        // U-Type: AUIPC (opcode = 0010111)
        test_immed(32'b00000000000100110000_00001_0010111, 32'h00130000);

        test_immed(32'b11111111101100000000001010010011, 32'hfffffffb);

        // Default: unsupported opcode → immediate = 0
        test_immed(32'hFFFFFFFF, 32'h00000000);

        $display("All tests complete.");
        $finish;
    end
endmodule