module maxtrix_tb ;
	logic clk;
	logic rst_n;
	logic set;
	logic start;
	logic [4:0] e12_in,e13_in,e14_in,e21_in,e23_in,e24_in,e31_in,e32_in,e34_in;

	logic [31:0] xp,xs,xl,xti;
	 logic [7:0] xn;
	 logic done;
	 logic [31:0] xpn,xsn,xln,xtin;

	 always #1 clk =~clk;
	 initial begin
	 	clk = 0;
	 	rst_n = 0;
	 	set = 0;
	 	e12_in = 5'd1;
	 	e13_in = 5'd2;
	 	e14_in = 5'd3;
	 	e21_in = 5'd4;
	 	e23_in = 5'd5;
	 	e24_in = 5'd6;
	 	e31_in = 5'd7;
	 	e32_in = 5'd8;
	 	e34_in = 5'd9;
	 	xp = 32'd1412442;
	 	xs= 32'd124241;
	 	xl = 32'd436436;
	 	xti = 32'd63464;
	 	start = 0;
	 end
	 initial begin
	 	#1 rst_n = 1;
	 	#2 set = 1;
	 	#4 set = 0;
	 	#2 start = 1;
	 	#2 start = 0;
	 	#20 $finish;
	 end
	 maxtrix maxtrix_tb(
	 	.clk   (clk),
	 	.rst_n (rst_n),
	 	.set   (set),
	 	.xl    (xl),
	 	.done  (done),
	 	.xln   (xln),
	 	.start (start),
	 	.e12_in(e12_in),
	 	.e13_in(e13_in),
	 	.e14_in(e14_in),
	 	.e21_in(e21_in),
	 	.e23_in(e23_in),
	 	.e24_in(e24_in),
	 	.e31_in(e31_in),
	 	.e32_in(e32_in),
	 	.e34_in(e34_in),
	 	.xp    (xp),
	 	.xs    (xs),
	 	.xti   (xti),
	 	.xn    (xn),
	 	.xpn   (xpn),.xsn   (xsn),
	 	.xtin  (xtin)
	 	);



endmodule : maxtrix_tb