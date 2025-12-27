`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2025 02:00:26
// Design Name: 
// Module Name: tb_pe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module tb_pe;

  // Parameters
  localparam int DATA_W = 16;
  localparam int ACC_W  = 32;

  // DUT signals
  logic                 clk;
  logic                 rst_n;

  logic                 valid_in;
  logic [DATA_W-1:0]    a_in;
  logic [DATA_W-1:0]    b_in;
  logic [ACC_W-1:0]     psum_in;

  logic                 valid_out;
  logic [DATA_W-1:0]    a_out;
  logic [DATA_W-1:0]    b_out;
  logic [ACC_W-1:0]     psum_out;

  // Instantiate PE
  pe #(
    .DATA_W(DATA_W),
    .ACC_W (ACC_W)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .valid_in  (valid_in),
    .a_in      (a_in),
    .b_in      (b_in),
    .psum_in   (psum_in),
    .valid_out (valid_out),
    .a_out     (a_out),
    .b_out     (b_out),
    .psum_out  (psum_out)
  );

  // --------------------------------------------------
  // Clock generation (100 MHz)
  // --------------------------------------------------
  always #5 clk = ~clk;

  // --------------------------------------------------
  // Main Test
  // --------------------------------------------------
  initial begin
    // Init
    clk      = 0;
    rst_n    = 0;
    valid_in = 0;
    a_in     = 0;
    b_in     = 0;
    psum_in  = 0;

    // Apply reset
    #20;
    rst_n = 1;

    // -----------------------------
    // Test 1: Single MAC operation
    // -----------------------------
    @(posedge clk);
    valid_in = 1;
    a_in     = 3;
    b_in     = 4;
    psum_in  = 0;

    @(posedge clk);
    valid_in = 0;

    @(posedge clk);
    if (psum_out != 12)
      $error("TEST1 FAILED: Expected 12, Got %0d", psum_out);
    else
      $display("TEST1 PASSED: psum_out = %0d", psum_out);

    // -----------------------------
    // Test 2: Accumulation
    // psum = 12 + (2 × 5) = 22
    // -----------------------------
    @(posedge clk);
    valid_in = 1;
    a_in     = 2;
    b_in     = 5;
    psum_in  = psum_out;

    @(posedge clk);
    valid_in = 0;

    @(posedge clk);
    if (psum_out != 22)
      $error("TEST2 FAILED: Expected 22, Got %0d", psum_out);
    else
      $display("TEST2 PASSED: psum_out = %0d", psum_out);

    // -----------------------------
    // Test 3: Data forwarding
    // -----------------------------
    if (a_out != 2 || b_out != 5)
      $error("TEST3 FAILED: a_out=%0d b_out=%0d", a_out, b_out);
    else
      $display("TEST3 PASSED: Data forwarded correctly");

    // -----------------------------
    // Test 4: valid propagation
    // -----------------------------
    if (!valid_out)
      $error("TEST4 FAILED: valid_out not asserted");
    else
      $display("TEST4 PASSED: valid_out asserted");

    // End simulation
    #20;
    $display("PE TESTBENCH COMPLETED SUCCESSFULLY");
    $finish;
  end

endmodule

