module logistic (
    input [31:0] xl,
    input clk,
    input rst_n,
    output logic [32:0] xln //33 bit num
);

    // Constants
    localparam INPUT_WIDTH  = 32;
    localparam OUTPUT_WIDTH = 2 * INPUT_WIDTH;
    
    // Internal signals
    logic [63:0] temp_1;
    
    // Constants
    localparam [31:0] const_3_2_30 = 32'b1100_0000_0000_0000_0000_0000_0000_0000;
    localparam [31:0] const_2_31 = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
    
    // Module Instances
    fix_mult #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH))
     fix_mult (
        .multiplicand(xl),
        .multiplier  ((~xl)+1'b1),
        .result      (temp_1) 
      );


     always_ff @(posedge clk or negedge rst_n) begin : proc_xln
         if(~rst_n) begin
             xln <= 0;
         end else begin
             if (xl == const_3_2_30 ) begin
            xln <= const_3_2_30 - 1;
        end else if (xl == const_2_31) begin
            xln <= 32'b1111_1111_1111_1111_1111_1111_1111_1111;
        end else begin
            xln <= temp_1[62:30];
        end
         end
     end

endmodule
