module fix_signmult #(
  parameter INPUT_WIDTH  = 16             ,
  parameter OUTPUT_WIDTH = 2 * INPUT_WIDTH 
)
(
  input        [INPUT_WIDTH-1:0 ] multiplicand, // Multiplicand
  input        [INPUT_WIDTH-1:0 ] multiplier  , // Multiplier
  output logic [OUTPUT_WIDTH-1:0] result        // Result
);

  // Assume that negative numbers have been represented in 2's complement

  //==============================================================================
  //                           Internal signals
  //==============================================================================

  logic [INPUT_WIDTH-1:0][2*INPUT_WIDTH-1:0] pre_result; // Pre result
  logic [INPUT_WIDTH-1:0][2*INPUT_WIDTH-1:0] sum       ; // Summary

  //==============================================================================
  //                               Computing
  //==============================================================================

  // pre_result
  genvar i;
  generate
    for (i = INPUT_WIDTH-1; i >= 0; i--) begin
      if (i == INPUT_WIDTH-1) begin
        always_comb begin : proc_pre_result_iw_max
          pre_result[i] = ({1'b1, (multiplicand[INPUT_WIDTH-1] & multiplier[i]), 
                           ~({(INPUT_WIDTH-1){multiplier[i]}} & multiplicand[INPUT_WIDTH-2:0])} << i);
        end
      end
      else if (i == 0) begin
        always_comb begin : proc_pre_result_iw_0
          pre_result[i] = ({1'b1, (~(multiplicand[INPUT_WIDTH-1] & multiplier[i])), 
                            {(INPUT_WIDTH-1){multiplier[i]}} & multiplicand[INPUT_WIDTH-2:0]} << i);
        end
      end
      else begin
        always_comb begin : proc_pre_result_iw_normal
          pre_result[i] = ({(~(multiplicand[INPUT_WIDTH-1] & multiplier[i])), 
                            {(INPUT_WIDTH-1){multiplier[i]}} & multiplicand[INPUT_WIDTH-2:0]}) << i;
        end
      end
    end
  endgenerate

  // sum
  assign sum[0] = pre_result[0];
  generate
    for (i = 1; i < INPUT_WIDTH; i++) begin
      assign sum[i] = pre_result[i] + sum[i-1];
    end
  endgenerate

  // result
  assign result = sum[INPUT_WIDTH-1];

endmodule : fix_signmult