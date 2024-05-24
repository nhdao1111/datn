
module PWLCM_map (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input wire [31:0] xp,
	input wire [30:0] pp,
	input wire start,
	output logic [31:0] xpn,
	output logic done
);
	wire [32:0] xp_in;
	wire [32:0] pp_in;
	assign xp_in ={0,xp};
	assign pp_in = {00,pp};
	logic [32:0] pre_result_1;
	logic pre_finish_1;
	logic pre_finish_2;
	logic pre_finish_3;
	logic pre_finish_4;
	logic  [33:0] sum_of_add2;
	logic  [33:0] sum_of_add3;
	logic [32:0] pre_result_2;
	logic [32:0] pre_result_3;
	logic [32:0] pre_result_4;
	logic  start_1;
	logic  start_2;
	logic  start_3;
	logic  start_4;
	logic [33:0] result;

	logic [2:0] state;
	parameter ST_IDLE = 3'd0,
			  ST_1 = 3'd1,
			  ST_2 = 3'd2,
			  ST_3 = 3'd3,
			  ST_4 = 3'd4;

 	
 		
	//case 1
	fix_div div1 (
			.clk                (clk),
			.rst_n              (rst_n),
			.i_dividend         (xp_in),
			.i_divisor          (pp_in),
			.i_start            (start_1),
			.o_complete         (pre_finish_1),
			.o_quotient_out_frac(pre_result_1)
			);
	// case 2
	fix_add add2 (
			.addend1(xp_in),
			.addend2({10,pp}),
			.sum(sum_of_add2)
		);

	fix_div div2 (
		.clk(clk),
		.rst_n(rst_n),
		.i_dividend({sum_of_add2[33],sum_of_add2[31:0]}),
		.i_divisor({00,(~pp)+1'b1}),
		.i_start(start_2),
		.o_complete(pre_finish_2),
		.o_quotient_out_frac(pre_result_2)

		);

	// case 3

	fix_add add3 (
		.addend1(xp_in),
		.addend2(pp_in),
		.sum    (sum_of_add3)
		);

	fix_div div3 (
		.clk                (clk),
		.rst_n              (rst_n),
		.i_start            (start_3),
		.i_dividend         ({0,(~sum_of_add3[31:0])+1'b1}),
		.i_divisor          ({00,(~pp)+1'b1}),
		.o_complete         (pre_finish_3),
		.o_quotient_out_frac(pre_result_3)
		);

	//case 4

	fix_div div4 (
		.clk                (clk),
		.rst_n              (rst_n),
		.i_start            (start_4),
		.i_dividend         ({0,(~xp)+1'b1}),
		.i_divisor          ({00,pp}),
		.o_complete (pre_finish_4),
		.o_quotient_out_frac(pre_result_4)
		);


	always_ff @(posedge clk or negedge rst_n) begin : proc_state
			if(~rst_n) begin
				state <= ST_IDLE;
			end else begin
				if (xp == 0 && pp == 0)
					begin
 					state <= ST_IDLE;	
 					end
					

				else if((xp >= 32'b0) && (xp < {0,pp}) ) begin
					start_1 <= start;
 					start_2 <= 0;
 					start_3 <= 0;
 					start_4 <= 0;
 					state  <= ST_1;	
				end
				else if (xp >= pp  && xp < 32'h80000000)
					begin
					start_2 <= start;
 					start_1 <= 0;
 					start_3 <= 0;
 					start_4 <= 0;
 					state  <= ST_2;	
					end
				else if  (xp >= 32'h80000000 && xp < (33'h10000_0000 - {00,pp} ) )
					begin
					start_3 <= start;
 					start_1 <= 0;
 					start_2 <= 0;
 					start_4 <= 0;
 					state  <= ST_3;	
					end				
				else if (xp >= (33'h100000000 - {00,pp} ) && xp < 33'h100000000)
					begin
					start_4 <= start;
 					start_1 <= 0;
 					start_2 <= 0;
 					start_3 <= 0;
 					state  <= ST_4;	
					end	
				else 
					state <= ST_IDLE;
			end
		end	

	always_ff @(posedge clk or negedge rst_n) begin : proc_xpn
		if(~rst_n) begin//
			xpn <= 0;
			done <= 0;

		end //
		else begin///
			//case1
			if(state == ST_1 ) begin//
			
				if (pre_finish_1 & (~start_1)) begin				
					xpn <= pre_result_1[32:1];
					done <= 1;
				end
				else begin
					xpn <= xpn;
					done <= 0;
				end

				end//
			// case2
			else if (state == ST_2) begin
				if (pre_finish_2 & (~start_2)) begin
					xpn <= pre_result_2[32:1];
					done <= 1;

				end
				else begin
					xpn <= xpn;
					done <=0;
				end 
			end 
			//case3
			else if (state == ST_3 ) begin
				if (pre_finish_3 & (~start_3)) begin
					xpn <= pre_result_3[32:1];
					done <=1 ;
				end
				else begin
					xpn <= xpn;
					done <= 0;
				end
			end
			else if (xp >= (33'h100000000 - {00,pp} ) && xp < 33'h100000000) begin
				if (pre_finish_4 &(~start_4)) begin
					xpn <= pre_result_4[32:1];
					done <= 1;
				end
				else
					xpn <= xpn;
					done <=0;
			end

			else begin
				xpn <= 0;
			end

	
	end///

end


endmodule : PWLCM_map

module PWLCM_map_tb ;
	logic clk;    // Clock
	logic rst_n;  // Asynchronous reset active low
	logic [31:0] xp;
	logic [30:0] pp;
	logic [31:0] xpn;
	logic i_start;
	logic done;
	PWLCM_map PWLCM_map(
		.clk(clk),
		.rst_n(rst_n),
		.xp(xp),
		.pp(pp),
		.xpn(xpn),
		.start(i_start),
		.done(done)

		);
	always #1 clk =~clk;
	initial begin
		i_start = 0;
		clk = 0;
		xp = 0;
		pp = 0;
		rst_n = 0;

	end
	initial begin
		#10; 
		rst_n = 1;
		#1 ;
		
		#3
		i_start = 1;
		xp = 32'd2147483799;
		pp = 31'd2034; 
		# 3 i_start = 0;
		#150;
		#3
		i_start = 1;
		xp = 32'd5253;
		
		#3
		i_start = 0;
		#150;
		#3 i_start = 1;
		xp = 32'd5252;
		
		#3 i_start = 0;
		#150;
		#3 i_start = 1;
		xp = 32'd5254;
		
		#3 i_start = 0;


		#200 $finish;
	end

endmodule : PWLCM_map_tb