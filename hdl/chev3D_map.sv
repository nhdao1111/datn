module chev3D_map (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [31:0] xt,
	output logic [32:0] xtn
	
);
	logic [33:0] xt_in_1,xt_in_2;
	logic [31:0] x_var;
	logic [63:0] x_var_exp2;
	logic [127:0] x_var_exp3;
	logic [33:0] mult_result;
	logic [37:0] add_result;
	logic [36:0] pre_result;
	logic [37:0] result;

	fix_add add1(
		.addend1({0,xt}),
		.addend2(33'h1_8000_0000),
		.sum    (xt_in_1)
		);
	fix_add add2(
		.addend1({1,xt}),
		.addend2(33'h0_8000_0000),
		.sum    (xt_in_2)
		);

	always_comb begin
		if(xt >= 32'h80000000)
 			begin
 			x_var = xt_in_1[31:0];
 			pre_result = {add_result[37],add_result[35:0]};	
 			end
 		 
 		else 
 			begin
 			x_var = xt_in_2[31:0];
 			pre_result = {~add_result[37],add_result[35:0]};	
 			end
	end
 	

 	fix_mult  #(
 		.INPUT_WIDTH(32),
 		.OUTPUT_WIDTH(64)
 		)
 	exp2
 	(
 		.multiplier  (x_var),
 		.multiplicand(x_var),
 		.result      (x_var_exp2)
 	 );

 	fix_mult #(
 		.INPUT_WIDTH(64),
 		.OUTPUT_WIDTH(128)
 		)
 	exp3 (
 		.multiplier  ({32'h0000_0000,x_var}),
 		.multiplicand(x_var_exp2),
 		.result      (x_var_exp3)
 		);
 	fix_mult #(
 		.INPUT_WIDTH (32),
 		.OUTPUT_WIDTH(34)
 		)
 	mult (
 		.multiplier  (x_var),
 		.multiplicand(32'h00000003),
 		.result      (mult_result)

 		);

 	fix_add #(
 		.N (36)
 		)
 	add_chev_1 (
 		.addend2({0,x_var_exp3[95:60]}),
 		.addend1({3'b100,mult_result}),
 		.sum    (add_result)
 		);
 	
 	fix_add #(
 		.N (36)
 		)
 	add_chev_2 (
 		.addend1(pre_result),
 		.addend2(37'h00_8000_0000),
 		.sum    (result)
 		);

 	always_ff @(posedge clk or negedge rst_n) begin : proc_xtn
 		if(~rst_n) begin
 			xtn <= 33'b0;
 		end else begin
 			xtn <= result[32:0];
 		end
 	end

	
endmodule : chev3D_map