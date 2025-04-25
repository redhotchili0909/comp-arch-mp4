## Overview

This project involves the design and implementation of a single-cycle 32-bit RISC-V integer microprocessor based on the Von Neumann architecture. The processor is developed using SystemVerilog and includes comprehensive testbenches to validate its functionality.​

## Features

*Implements a subset of the RISC-V instruction set architecture (ISA)

*Single-cycle execution model

*Von Neumann architecture with unified instruction and data memory

*Modular design for components such as ALU, register file, and control unit

*Testbenches for individual modules to ensure correctness​

## Directory Structure

modules/: Contains the SystemVerilog modules for various components of the processor.

sim_res/: Holds simulation results and waveform files.

alu_tb.sv: Testbench for the Arithmetic Logic Unit (ALU).

immed_gen_tb.sv: Testbench for the immediate value generator.

program_counter_tb.sv: Testbench for the program counter module.

register_file_tb.sv: Testbench for the register file.

state_machine_tb.sv: Testbench for the control state machine
