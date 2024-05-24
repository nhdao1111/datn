module maxtrix (
	input clk,    // Clock
	input [4:0] e12_in,e13_in,e14_in,e21_in,e23_in,e24_in,e31_in,e32_in,e34_in,
	input set,
	input start, 
	input rst_n,  // Asynchronous reset active low
	input [31:0] xp,xs,xl,xti,
	output logic [7:0] xn,
	output logic done,
	output logic [31:0] xpn,xsn,xln,xtin
 
);
	localparam INPUT_WIDTH = 32;
		//caculate M
	logic [31:0] M11,M22,M33,M44;
	logic [7:0] pre_M11,pre_M22,pre_M33,pre_M44;
	logic [6:0]sum_M1_1,sum_M2_1,sum_M3_1,sum_M4_1;
	logic [4:0] e12,e13,e14,e21,e23,e24,e31,e32,e34;
	//M11
	fix_add #(.N(5))
	add_M1_1(
		.addend1({1'b0,e12}),
		.addend2({1'b0,e13}),
		.sum    (sum_M1_1)
		);
	fix_add #(.N(6))
	add_M1_2(
		.addend1(sum_M1_1),
		.addend2({2'b00,e14}),
		.sum    (pre_M11)
		);
	//M22
	fix_add #(.N(5))
	add_M2_1(
		.addend1({1'b0,e21}),
		.addend2({1'b0,e23}),
		.sum    (sum_M2_1)
		);
	fix_add #(.N(6))
	add_M2_2(
		.addend1(sum_M2_1),
		.addend2({2'b00,e24}),
		.sum    (pre_M22)
		);

	//M33

	fix_add #(.N(5))
	add_M3_1(
		.addend1({1'b0,e31}),
		.addend2({1'b0,e32}),
		.sum    (sum_M3_1)
		);
	fix_add #(.N(6))
	add_M3_2(
		.addend1(sum_M3_1),
		.addend2({2'b00,e34}),
		.sum    (pre_M33)
		);
	
	//M44

	fix_add #(.N(5))
	add_M4_1(
		.addend1({1'b0,e12}),
		.addend2({1'b0,e13}),
		.sum    (sum_M4_1)
		);
	fix_add #(.N(6))
	add_M4_2(
		.addend1(sum_M4_1),
		.addend2({2'b00,e14}),
		.sum    (pre_M44)
		);

	assign M11 = (~{24'b0,pre_M11})+1'b1;
	assign M22 = (~{24'b0,pre_M22})+1'b1;
	assign M33 = (~{24'b0,pre_M33})+1'b1;
	assign M44 = (~{24'b0,pre_M44})+1'b1;

	//calculate matrix

	logic [63:0] mult_result_11,mult_result_12,mult_result_13,mult_result_14;
	logic [65:0] add_result_11,add_result_12;
	logic [66:0] row1;
	//row 1
	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row1_1 (
		.multiplier  (xp),
		.multiplicand(M11),
		.result      (mult_result_11)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row1_2 (
		.multiplier  (xs),
		.multiplicand({27'b0,e12}),
		.result      (mult_result_12)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)

	mult_row1_3 (
		.multiplier  (xl),
		.multiplicand({27'b0,e13}),
		.result      (mult_result_13)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row1_4 (
		.multiplier  (xti),
		.multiplicand({27'b0,e14}),
		.result      (mult_result_14)
		);

	fix_add #(.N(64))
	add_row11 (
		.addend2({0,mult_result_11}),
		.addend1({0,mult_result_12}),
		.sum    (add_result_11)
		);

	fix_add #(.N(64))
	add_row12 (
		.addend2({0,mult_result_13}),
		.addend1({0,mult_result_14}),
		.sum    (add_result_12)
		);

	fix_add #(.N(65))
	add_row1 (
		.addend2(add_result_11),
		.addend1(add_result_12),
		.sum    (row1)
		);

	// row2
	
	logic [63:0] mult_result_21,mult_result_22,mult_result_23,mult_result_24;
	logic [65:0] add_result_21,add_result_22;
	logic [66:0] row2;

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row2_1 (
		.multiplier  (xp),
		.multiplicand({27'b0,e21}),
		.result      (mult_result_21)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row2_2 (
		.multiplier  (xs),
		.multiplicand(M22),
		.result      (mult_result_22)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)

	mult_row2_3 (
		.multiplier  (xl),
		.multiplicand({27'b0,e23}),
		.result      (mult_result_23)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row2_4 (
		.multiplier  (xti),
		.multiplicand({27'b0,e24}),
		.result      (mult_result_24)
		);

	fix_add #(.N(64))
	add_row21 (
		.addend2({0,mult_result_21}),
		.addend1({0,mult_result_22}),
		.sum    (add_result_21)
		);

	fix_add #(.N(64))
	add_row22 (
		.addend2({0,mult_result_23}),
		.addend1({0,mult_result_24}),
		.sum    (add_result_22)
		);

	fix_add #(.N(65))
	add_row2 (
		.addend2(add_result_21),
		.addend1(add_result_22),
		.sum    (row2)
		);

	//row 3

	logic [63:0] mult_result_31,mult_result_32,mult_result_33,mult_result_34;
	logic [65:0] add_result_31,add_result_32;
	logic [66:0] row3;

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row3_1 (
		.multiplier  (xp),
		.multiplicand({27'b0,e31}),
		.result      (mult_result_31)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row3_2 (
		.multiplier  (xs),
		.multiplicand({27'b0,e32}),
		.result      (mult_result_32)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)

	mult_row3_3 (
		.multiplier  (xl),
		.multiplicand(M33),
		.result      (mult_result_33)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row3_4 (
		.multiplier  (xti),
		.multiplicand({27'b0,e34}),
		.result      (mult_result_34)
		);

	fix_add #(.N(64))
	add_row31 (
		.addend2({0,mult_result_31}),
		.addend1({0,mult_result_32}),
		.sum    (add_result_31)
		);

	fix_add #(.N(64))
	add_row32 (
		.addend2({0,mult_result_33}),
		.addend1({0,mult_result_34}),
		.sum    (add_result_32)
		);

	fix_add #(.N(65))
	add_row3 (
		.addend2(add_result_31),
		.addend1(add_result_32),
		.sum    (row3)
		);

	// row4

	

	logic [63:0] mult_result_41,mult_result_42,mult_result_43,mult_result_44;
	logic [65:0] add_result_41,add_result_42;
	logic [66:0] row4;

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row4_1 (
		.multiplier  (xp),
		.multiplicand({27'b0,e12}),
		.result      (mult_result_41)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row4_2 (
		.multiplier  (xs),
		.multiplicand({27'b0,e13}),
		.result      (mult_result_42)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)

	mult_row4_3 (
		.multiplier  (xl),
		.multiplicand({27'b0,e14}),
		.result      (mult_result_43)
		);

	fix_mult #(
		.INPUT_WIDTH (32),
		.OUTPUT_WIDTH(2 * INPUT_WIDTH)
		)
	mult_row4_4 (
		.multiplier  (xti),
		.multiplicand(M44),
		.result      (mult_result_44)
		);

	fix_add #(.N(64))
	add_row41 (
		.addend2({0,mult_result_41}),
		.addend1({0,mult_result_42}),
		.sum    (add_result_41)
		);

	fix_add #(.N(64))
	add_row42 (
		.addend2({0,mult_result_43}),
		.addend1({0,mult_result_44}),
		.sum    (add_result_42)
		);

	fix_add #(.N(65))
	add_row4 (
		.addend2(add_result_41),
		.addend1(add_result_42),
		.sum    (row4)
		);

	logic[66:0] pre_xn;

	assign pre_xn = row1^row2^row3^row4;
	always_ff @(posedge clk or negedge rst_n) begin : proc_xn
		if(~rst_n) begin
			xn <= 0;
			xpn <=0;
			xsn <= 0;
			xln <=0;
			xtin <= 0;
			done <=0;
		end else begin
			if (start) begin
				xn <= pre_xn [8:0];
				done <= 1;
				xpn <= row1[31:0];
				xsn <= row2[31:0];
				xln <= row3[31:0];
				xtin <= row4[31:0];
			end
			else
				begin
					xn <= xn;
				done <= 0;
				xpn <= xpn;
				xsn <= xsn;
				xln <= xln;
				xtin <= xtin;
			
				end
				
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_e
		if(~rst_n) begin
			e12 <= 0;
			e13 <= 0;
			e14 <= 0;
			e21 <= 0;
			e23 <= 0;
			e24 <= 0;
			e31 <= 0;
			e32 <= 0;
			e34 <= 0;
		end else begin
			if (set) begin
				e12 <= e12_in;
				e13 <= e13_in;
				e14 <= e14_in;
				e21 <= e21_in;
				e23 <= e23_in;
				e24 <= e24_in;
				e31 <= e31_in;
				e32 <= e32_in;
				e34 <= e34_in;
			end
			else begin
				e12 <= e12;
				e13 <= e13;
				e14 <= e14;
				e21 <= e21;
				e23 <= e23;
				e24 <= e24;
				e31 <= e31;
				e32 <= e32;
				e34 <= e34;
			end
		end
	end









endmodule : maxtrix