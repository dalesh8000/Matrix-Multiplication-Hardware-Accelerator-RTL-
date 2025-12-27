module pe #(
  parameter int DATA_W = 16,
  parameter int ACC_W  = 32
)(
  input  logic                 clk,
  input  logic                 rst_n,

  input  logic                 valid_in,
  input  logic [DATA_W-1:0]    a_in,
  input  logic [DATA_W-1:0]    b_in,
  input  logic [ACC_W-1:0]     psum_in,

  output logic                 valid_out,
  output logic [DATA_W-1:0]    a_out,
  output logic [DATA_W-1:0]    b_out,
  output logic [ACC_W-1:0]     psum_out
);

  // Internal multiplication result
  logic [ACC_W-1:0] mult_result;

  assign mult_result = a_in * b_in;

  // Sequential logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      a_out     <= '0;
      b_out     <= '0;
      psum_out  <= '0;
      valid_out <= 1'b0;
    end
    else begin
      valid_out <= valid_in;

      if (valid_in) begin
        a_out    <= a_in;                 // pass A to right
        b_out    <= b_in;                 // pass B to bottom
        psum_out <= psum_in + mult_result; // MAC operation
      end
    end
  end

endmodule
