module controller #(
  parameter int N = 4,                 // 4x4 systolic array
  parameter int K = 4                  // inner dimension (A NxK × B KxN)
)(
  input  logic clk,
  input  logic rst_n,

  input  logic start,                  // start signal

  output logic valid_en,               // enables systolic array
  output logic done,                   // computation done
  output logic busy                    // accelerator busy
);
  typedef enum logic [1:0] {
    IDLE,
    LOAD,
    COMPUTE,
    DONE
  } state_t;

  state_t state, next_state;
  localparam int TOTAL_CYCLES = K + (2*N) - 1;
  logic [$clog2(TOTAL_CYCLES+1)-1:0] cycle_cnt;
  always_ff @(posedge clk) begin
    if (!rst_n)
      state <= IDLE;
    else
      state <= next_state;
  end
  always_comb begin
    next_state = state;

    case (state)
      IDLE: begin
        if (start)
          next_state = LOAD;
      end

      LOAD: begin
        next_state = COMPUTE;
      end

      COMPUTE: begin
        if (cycle_cnt == TOTAL_CYCLES)
          next_state = DONE;
      end

      DONE: begin
        next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      cycle_cnt <= '0;
      valid_en  <= 1'b0;
      done      <= 1'b0;
      busy      <= 1'b0;
    end
    else begin
      case (state)

        IDLE: begin
          cycle_cnt <= '0;
          valid_en  <= 1'b0;
          done      <= 1'b0;
          busy      <= 1'b0;
        end

        LOAD: begin
          valid_en  <= 1'b1;   // start feeding data
          busy      <= 1'b1;
        end

        COMPUTE: begin
          valid_en  <= 1'b1;
          busy      <= 1'b1;
          cycle_cnt <= cycle_cnt + 1'b1;
        end

        DONE: begin
          valid_en  <= 1'b0;
          busy      <= 1'b0;
          done      <= 1'b1;
        end

      endcase
    end
  end

endmodule
