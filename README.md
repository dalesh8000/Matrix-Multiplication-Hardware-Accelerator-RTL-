# AXI-Stream Based Matrix Multiplication Hardware Accelerator using 4×4 Systolic Array (RTL Design)
# Overview:
This project implements a hardware accelerator for matrix multiplication using a 4×4 systolic array architecture, written entirely in SystemVerilog (RTL). The accelerator is integrated with AXI-Stream interfaces for input and output, making it suitable for SoC-level integration.The design focuses on clean datapath–control separation, pipelined MAC operations, and industry-standard AXI handshaking, making it an ideal RTL front-end design project.
# Key Concepts Used
-Systolic array architecture
-Pipelined Multiply–Accumulate (MAC) units
-AXI-Stream protocol (TVALID, TREADY, TLAST)
-FSM-based controller
-Bottom-up RTL design methodology
-Parameterized and scalable SystemVerilog code

# Architecture
High-Level Block Diagram
AXI-Stream IN
     │
     ▼
AXI Input Adapter
     │
     ▼
Controller FSM ──► 4×4 Systolic Array (16 PEs)
     │                     │
     ▼                     ▼
AXI Output Adapter ◄── Result Matrix
     │
     ▼
AXI-Stream OUT



# Dataflow

Matrix A elements flow horizontally across rows
Matrix B elements flow vertically down columns
Partial sums propagate diagonally
Each Processing Element (PE) performs:
psum_out = psum_in + (A × B)

# Module Description
-pe.sv
Basic Processing Element (PE)
Performs pipelined MAC operation
Forwards A, B, and partial sum

-systolic_array.sv
Instantiates 16 PEs in a 4×4 grid
Implements systolic data movement

-controller.sv
FSM-based control logic
States: IDLE → LOAD → COMPUTE → DONE
Handles timing, cycle counting, and completion signaling

-axi_input_adapter.sv
AXI-Stream slave interface
Buffers incoming data
Converts serial AXI data into parallel a_in[] and b_in[]

-axi_output_adapter.sv
AXI-Stream master interface
Streams output matrix in row-major order
Asserts TLAST on final element

-top_accel.sv
Top-level integration module
Connects controller, datapath, and AXI interfaces

# Verification Strategy
Testbenches Included
-tb_pe.sv
Verifies MAC operation, accumulation, forwarding, and valid propagation

-tb_top.sv
End-to-end system test
Drives AXI input streams
Captures AXI output streams
Verifies TLAST and done signaling

# Verification Approach
Bottom-up RTL verification
Directed testing

AXI handshake validation

Waveform-based debugging
