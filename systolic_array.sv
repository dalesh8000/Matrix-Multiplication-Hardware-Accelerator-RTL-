module systolic_array #(
  parameter int DATA_W = 16,
  parameter int ACC_W  = 32,
  parameter int N      = 4
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic                    valid_in,

  input  logic [DATA_W-1:0]       a_in [N], // left inputs
  input  logic [DATA_W-1:0]       b_in [N], // top inputs

  output logic                    valid_out,
  output logic [ACC_W-1:0]        c_out [N][N] // result matrix
);

  logic [DATA_W-1:0] a_wire   [N][N+1];
  logic [DATA_W-1:0] b_wire   [N+1][N];
  logic [ACC_W-1:0]  psum_wire[N+1][N+1];
  logic              valid_wire[N+1][N+1];
  genvar i, j;

  // Inject A inputs (left side)
  generate
    for (i = 0; i < N; i++) begin
      assign a_wire[i][0] = a_in[i];
    end
  endgenerate

  // Inject B inputs (top side)
  generate
    for (j = 0; j < N; j++) begin
      assign b_wire[0][j] = b_in[j];
    end
  endgenerate
  // Initialize partial sums to zero
  generate
    for (i = 0; i <= N; i++) begin
      for (j = 0; j <= N; j++) begin
        assign psum_wire[i][j]  = '0;
        assign valid_wire[i][j] = valid_in;
      end
    end
  endgenerate
  generate
    for (i = 0; i < N; i++) begin : ROW
      for (j = 0; j < N; j++) begin : COL

        pe #(
          .DATA_W(DATA_W),
          .ACC_W (ACC_W)
        ) pe_inst (
          .clk       (clk),
          .rst_n     (rst_n),

          .valid_in  (valid_wire[i][j]),

          .a_in      (a_wire[i][j]),
          .b_in      (b_wire[i][j]),
          .psum_in   (psum_wire[i][j]),

          .valid_out (valid_wire[i+1][j+1]),
          .a_out     (a_wire[i][j+1]),
          .b_out     (b_wire[i+1][j]),
          .psum_out  (psum_wire[i+1][j+1])
        );

      end
    end
  endgenerate
  generate
    for (i = 0; i < N; i++) begin
      for (j = 0; j < N; j++) begin
        assign c_out[i][j] = psum_wire[i+1][j+1];
      end
    end
  endgenerate

  assign valid_out = valid_wire[N][N];

endmodule
