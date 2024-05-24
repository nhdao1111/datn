module chev3D_map_tb ;
	logic clk;
	logic rst_n;
	logic [31:0] xt;
	logic [32:0] xtn;
	always #1 clk = ~clk;
	chev3D_map chev3D_map_tb(
		.clk  (clk),
		.xt   (xt),
		.rst_n(rst_n),
		.xtn  (xtn)

		);
	initial begin
	 rst_n = 0;
	 clk = 0;
	 xt = 0;
	 #3 rst_n = 1;
	 #10 xt = 32'd124;
	  #10 xt = 32'd1245;
	   #10 xt = 32'd53224;
	    #10 xt = 32'd1073741824;
	    #10 $finish;
	end

endmodule : chev3D_map_tb