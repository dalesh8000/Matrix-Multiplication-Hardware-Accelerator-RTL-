module axi_output_adapter #(
  parameter int ACC_W = 32,
  parameter int N     = 4
)(
  input  logic                  clk,
  input  logic                  rst_n,

  // Control from controller
  input  logic                  enable,      // start streaming
  input  logic                  data_valid,  // output matrix ready

  // Output matrix from systolic array
  input  logic [ACC_W-1:0]      c_out [N][N],

  // AXI-Stream Master Interface
  output logic                  m_axis_tvalid,
  output logic [ACC_W-1:0]      m_axis_tdata,
  output logic                  m_axis_tlast,
  input  logic                  m_axis_tready
);

  // Counter for output elements
  logic [$clog2(N*N+1)-1:0] send_cnt;

  // AXI valid when enabled and data is available
  assign m_axis_tvalid = enable && data_valid && (send_cnt < N*N);

  // Output data selection (row-major order)
  always_comb begin
    int row, col;
    row = send_cnt / N;
    col = send_cnt % N;
    m_axis_tdata = c_out[row][col];
  end

  // TLAST on final element
  assign m_axis_tlast = (send_cnt == (N*N - 1)) && m_axis_tvalid;

  // Sequential logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      send_cnt <= '0;
    end
    else begin
      // Advance only on successful AXI handshake
      if (m_axis_tvalid && m_axis_tready) begin
        send_cnt <= send_cnt + 1'b1;
      end

      // Reset counter when disabled
      if (!enable) begin
        send_cnt <= '0;
      end
    end
  end

endmodule
