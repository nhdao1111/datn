`timescale 1ns/1ps

module fix_signmult_tb ();
parameter INPUT_WIDTH  = 16;
parameter OUTPUT_WIDTH = 2 * INPUT_WIDTH; 
logic [INPUT_WIDTH-1:0 ] multiplicand;
logic [INPUT_WIDTH-1:0 ] multiplier  ;
logic [OUTPUT_WIDTH-1:0] result      ;

fix_signmult #(
  .INPUT_WIDTH  (INPUT_WIDTH  ),
  .OUTPUT_WIDTH (OUTPUT_WIDTH ) 
) x1 (
  .multiplicand (multiplicand ),
  .multiplier   (multiplier   ),
  .result       (result       )
);

initial begin
  #10;
  multiplicand = 16'd100;
  multiplier   = 16'd5  ;
  #100;
  multiplicand = 16'b1100000010010000;
  multiplier   = 16'd75  ;
  #100;
  $stop;
end

endmodule