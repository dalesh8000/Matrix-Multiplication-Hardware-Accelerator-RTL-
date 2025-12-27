`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2025 01:46:56
// Design Name: 
// Module Name: top_accel
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


module top_accel #(
  parameter int DATA_W = 16,
  parameter int ACC_W  = 32,
  parameter int N      = 4
)(
  input  logic                 clk,
  input  logic                 rst_n,

  // Control
  input  logic                 start,
  output logic                 done,
  output logic                 busy,

  // AXI-Stream Slave (Input)
  input  logic                 s_axis_tvalid,
  input  logic [DATA_W-1:0]    s_axis_tdata,
  output logic                 s_axis_tready,

  // AXI-Stream Master (Output)
  output logic                 m_axis_tvalid,
  output logic [ACC_W-1:0]     m_axis_tdata,
  output logic                 m_axis_tlast,
  input  logic                 m_axis_tready
);

  // --------------------------------------------------
  // Internal Signals
  // --------------------------------------------------

  logic                    valid_en;
  logic                    inputs_valid;

  logic [DATA_W-1:0]       a_in [N];
  logic [DATA_W-1:0]       b_in [N];

  logic                    sa_valid_out;
  logic [ACC_W-1:0]        c_out [N][N];

  // --------------------------------------------------
  // Controller
  // --------------------------------------------------

  controller #(
    .N(N),
    .K(N)
  ) u_controller (
    .clk       (clk),
    .rst_n     (rst_n),
    .start     (start),
    .valid_en  (valid_en),
    .done      (done),
    .busy      (busy)
  );

  // --------------------------------------------------
  // AXI Input Adapter
  // --------------------------------------------------

  axi_input_adapter #(
    .DATA_W(DATA_W),
    .N      (N)
  ) u_axi_input (
    .clk           (clk),
    .rst_n         (rst_n),

    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tready (s_axis_tready),

    .enable        (valid_en),

    .a_in          (a_in),
    .b_in          (b_in),
    .inputs_valid  (inputs_valid)
  );

  // --------------------------------------------------
  // Systolic Array (Datapath)
  // --------------------------------------------------

  systolic_array #(
    .DATA_W(DATA_W),
    .ACC_W (ACC_W),
    .N     (N)
  ) u_systolic_array (
    .clk       (clk),
    .rst_n     (rst_n),

    .valid_in  (inputs_valid),

    .a_in      (a_in),
    .b_in      (b_in),

    .valid_out (sa_valid_out),
    .c_out     (c_out)
  );

  // --------------------------------------------------
  // AXI Output Adapter
  // --------------------------------------------------

  axi_output_adapter #(
    .ACC_W (ACC_W),
    .N     (N)
  ) u_axi_output (
    .clk           (clk),
    .rst_n         (rst_n),

    .enable        (valid_en),
    .data_valid    (sa_valid_out),

    .c_out         (c_out),

    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tready (m_axis_tready)
  );

endmodule

