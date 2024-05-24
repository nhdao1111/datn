module SkewT_map (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input wire [31:0] xs,
	input wire [31:0] ps,
	input wire start,
	output logic [31:0] xsn,
	output logic done
);
	parameter ST_IDLE = 2'b00,
			  ST_1    = 2'b01,
			  ST_2    = 2'b10,
			  ST_3    = 2'b11;


	logic [1:0] state;
	logic start_1;
	logic start_2;
	logic pre_finish_1;
	logic pre_finish_2;
	logic [32:0] pre_result_1;
	logic [32:0] pre_result_2;



	//case 1
	fix_div div1 (
		.clk                (clk),
		.rst_n              (rst_n),
		.i_dividend         ({0,xs}),
		.i_divisor          ({0,ps}),
		.i_start            (start_1),
		.o_complete         (pre_finish_1),
		.o_quotient_out_frac(pre_result_1)

		);
	//case2
	fix_div div2 (
		.clk                (clk),
		.rst_n              (rst_n),
		.i_dividend         ({0,~(xs)+1'b1}),
		.i_divisor          ({0,~(ps)+1'b1}),
		.i_start            (start_2),
		.o_complete         (pre_finish_2),
		.o_quotient_out_frac(pre_result_2)

		);

	// case3	


	always_ff @(posedge clk or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= ST_IDLE;
		end else begin
			if ((xs > 0) && (xs < ps) ) begin
				state <= ST_1;
				start_1 <= start;
				start_2 <= 0;
			end
			else if ((xs > ps) && (xs < 33'h100000000) ) begin
				state <= ST_2;
				start_1 <= 0;
				start_2 <= start;
			end
			else begin
				state <= ST_3;
				start_1 <= 0;
				start_2 <= 0;
			end
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_xsn
		if(~rst_n) begin
			xsn <= 0;
			done <= 0;
		end else begin
			//case1
			if(state == ST_1) begin
				if (pre_finish_1  & (~start_1 )  ) begin
					xsn <= pre_result_1[32:1];
					done <= 1;
				end
				else begin
					xsn <= xsn;
					done <= 0;
				end
			end
			//case2
			else if (state == ST_2) begin
				if (pre_finish_2  & (~start_2)) begin
					xsn <= pre_result_2[32:1];
					done <= 1;
				end
				else begin
					xsn <= xsn;
					done <= 0;
				end
			end
			else if (state == ST_3 ) begin
				if(start ) begin
					xsn <= 32'hffffffff;
					done <= 1;
				end
				else
					done <=0;
				
			end
			else
				xsn <= 0 ;
		end
	end

endmodule : SkewT_map

module SkewT_map_tb ;
	logic clk;    // Clock
	logic rst_n;  // Asynchronous reset active low
	logic [31:0] xs;
	logic [31:0] ps;
	logic [31:0] xsn;
	logic i_start;
	logic done;
	SkewT_map SkewT_map(
		.clk(clk),
		.rst_n(rst_n),
		.xs(xs),
		.ps(ps),
		.xsn(xsn),
		.start(i_start),
		.done(done)

		);
	always #1 clk =~clk;
	initial begin
		i_start = 0;
		clk = 0;
		xs = 0;
		ps = 1;
		rst_n = 0;
	end
	initial begin
		#10 rst_n = 1;
		#2 i_start = 1;
		xs = 32'd54321;
		ps = 32'd65432;
		#3 i_start = 0;
		#140;
		#2 i_start = 1;
		xs = 32'd53321;
		#3 i_start = 0;
		#140;
		#2 i_start = 1;
		xs = 32'd5321;
		#3 i_start = 0;
		#140;
		#2 i_start = 1;
		xs = 32'd71234;
		#3 i_start = 0;
		#140;
		#2 i_start = 1;
		xs = 32'd72234;
		#2 i_start = 0;
		#150
		#3 i_start = 1;
		xs = 32'd1;
		#2 i_start = 0;

		#140;
		i_start = 1;
		xs = 32'd0;
		#3 i_start = 0;
		xs = 32'd65432;
		#20 $finish;




	end

endmodule : SkewT_map_tb