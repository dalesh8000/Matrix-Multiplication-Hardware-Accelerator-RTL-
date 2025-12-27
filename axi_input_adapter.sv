`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2025 01:26:07
// Design Name: 
// Module Name: axi_input_adapter
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


module axi_input_adapter #(
  parameter int DATA_W = 16,
  parameter int N      = 4
)(
  input  logic                 clk,
  input  logic                 rst_n,

  // AXI-Stream Slave Interface
  input  logic                 s_axis_tvalid,
  input  logic [DATA_W-1:0]    s_axis_tdata,
  output logic                 s_axis_tready,

  // Control from controller
  input  logic                 enable,

  // Outputs to systolic array
  output logic [DATA_W-1:0]    a_in [N],
  output logic [DATA_W-1:0]    b_in [N],
  output logic                 inputs_valid
);

  // Counter to track received AXI words
  logic [$clog2(2*N+1)-1:0] recv_cnt;

  // AXI ready when enabled and buffer not full
  assign s_axis_tready = enable && (recv_cnt < 2*N);

  // Sequential logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      recv_cnt     <= '0;
      inputs_valid <= 1'b0;

      for (int i = 0; i < N; i++) begin
        a_in[i] <= '0;
        b_in[i] <= '0;
      end
    end
    else begin
      inputs_valid <= 1'b0;

      // Accept AXI data when handshake succeeds
      if (s_axis_tvalid && s_axis_tready) begin

        // First N beats → Matrix A
        if (recv_cnt < N) begin
          a_in[recv_cnt] <= s_axis_tdata;
        end
        // Next N beats → Matrix B
        else if (recv_cnt < 2*N) begin
          b_in[recv_cnt - N] <= s_axis_tdata;
        end

        recv_cnt <= recv_cnt + 1'b1;
      end

      // All inputs received
      if (recv_cnt == 2*N) begin
        inputs_valid <= 1'b1;
      end

      // Reset when controller disables input
      if (!enable) begin
        recv_cnt <= '0;
      end
    end
  end

endmodule
