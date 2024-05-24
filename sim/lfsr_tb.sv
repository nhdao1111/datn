module lfsr_tb ;
	logic clk;
	logic rst_n;
	logic set;
	logic shift;
	logic [31:0]lfsr_seed;
	logic [31:0]lfsr_state;
	logic done ;
	lfsr lfsr_tb(
		.clk       (clk),
		.rst_n     (rst_n),
		.set     (set),
		.shift     (shift),
		.lfsr_seed (lfsr_seed),
		.lfsr_state(lfsr_state),
		.done      (done)

		);

	always #1 clk =~clk;
	initial begin
		clk = 0;
		rst_n = 0;
		set =0;
		shift = 0;
		lfsr_seed = 32'h8020_0003;
		#1 rst_n = 1;
		#5 set = 1;
		#5 set = 0;
		#1 shift = 1;
		#2 shift = 0;
		#2 shift = 1;
		#2 shift = 0;
		#2 shift = 1;
		#2 shift = 0;
		#2 shift = 1;
		#2 shift = 0;
		#50 $finish;
	end

endmodule : lfsr_tb