`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2025 02:04:52
// Design Name: 
// Module Name: tb_top1
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

module tb_top;

  // --------------------------------------------------
  // Parameters
  // --------------------------------------------------
  localparam int DATA_W = 16;
  localparam int ACC_W  = 32;
  localparam int N      = 4;

  // --------------------------------------------------
  // Clock & Reset
  // --------------------------------------------------
  logic clk;
  logic rst_n;

  // --------------------------------------------------
  // Control
  // --------------------------------------------------
  logic start;
  logic done;
  logic busy;

  // --------------------------------------------------
  // AXI-Stream Input
  // --------------------------------------------------
  logic                 s_axis_tvalid;
  logic [DATA_W-1:0]    s_axis_tdata;
  logic                 s_axis_tready;

  // --------------------------------------------------
  // AXI-Stream Output
  // --------------------------------------------------
  logic                 m_axis_tvalid;
  logic [ACC_W-1:0]     m_axis_tdata;
  logic                 m_axis_tlast;
  logic                 m_axis_tready;
int out_count;
  // --------------------------------------------------
  // DUT
  // --------------------------------------------------
  top_accel #(
    .DATA_W(DATA_W),
    .ACC_W (ACC_W),
    .N     (N)
  ) dut (
    .clk            (clk),
    .rst_n          (rst_n),
    .start          (start),
    .done           (done),
    .busy           (busy),

    .s_axis_tvalid  (s_axis_tvalid),
    .s_axis_tdata   (s_axis_tdata),
    .s_axis_tready  (s_axis_tready),

    .m_axis_tvalid  (m_axis_tvalid),
    .m_axis_tdata   (m_axis_tdata),
    .m_axis_tlast   (m_axis_tlast),
    .m_axis_tready  (m_axis_tready)
  );

  // --------------------------------------------------
  // Clock: 100 MHz
  // --------------------------------------------------
  always #5 clk = ~clk;

  // --------------------------------------------------
  // AXI Send Task (FIXED)
  // --------------------------------------------------
  task automatic axi_send(input logic [DATA_W-1:0] data);
    begin
      // Drive data and valid
      s_axis_tdata  <= data;
      s_axis_tvalid <= 1'b1;

      // Wait until handshake completes
      while (!s_axis_tready)
        @(posedge clk);

      @(posedge clk);
      s_axis_tvalid <= 1'b0;
      s_axis_tdata  <= '0;
    end
  endtask

  // --------------------------------------------------
  // Main Test
  // --------------------------------------------------
  initial begin
    // Init
    clk            = 0;
    rst_n          = 0;
    start          = 0;
    s_axis_tvalid  = 0;
    s_axis_tdata   = 0;
    m_axis_tready  = 1;   // Always ready

    // Reset
    #20;
    rst_n = 1;

    // Start accelerator
    @(posedge clk);
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;

    // -------------------------------
    // Send Matrix A (4 elements)
    // -------------------------------
    axi_send(16'd1);
    axi_send(16'd2);
    axi_send(16'd3);
    axi_send(16'd4);

    // -------------------------------
    // Send Matrix B (4 elements)
    // -------------------------------
    axi_send(16'd5);
    axi_send(16'd6);
    axi_send(16'd7);
    axi_send(16'd8);

    // -------------------------------
    // Receive Output Matrix
    // -------------------------------
    $display("\n---- OUTPUT MATRIX ----");
    out_count = 0;

    while (out_count < N*N) begin
      @(posedge clk);
      if (m_axis_tvalid && m_axis_tready) begin
        $display("C[%0d] = %0d", out_count, m_axis_tdata);
        if (m_axis_tlast)
          $display("TLAST asserted");
        out_count++;
      end
    end

    // Wait for done
    wait (done);
    $display("\nCOMPUTATION DONE");

    #20;
    $finish;
  end

endmodule

