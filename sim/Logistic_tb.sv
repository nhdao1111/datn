module logistic_tb;

    // Parameters

    // Signals
    logic [31:0] xl;
    logic clk;
    logic rst_n;
    logic [33:0] xln;

    // Instantiate the logistic module
    logistic dut (
        .xl(xl),
        .clk  (clk),
        .rst_n(rst_n),
        .xln(xln)
    );

    always #1 clk = ~clk;
    // Test cases
    initial begin
        // Test case 1: xl = 0
        rst_n = 0;
        clk = 0;
        #2
        rst_n = 1;
        xl = 32'b0;
        #10;
        $display("Test Case 1: xl = 0, xln = %h", xln);

        // Test case 2: xl = 3*2^30
        xl = 32'b1100_0000_0000_0000_0000_0000_0000_0000;
        #10;
        $display("Test Case 2: xl = 3*2^30, xln = %h", xln);

        // Test case 3: xl = 2^32
        xl = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
        #10;
        $display("Test Case 3: xl = 2^32, xln = %h", xln);

        // Test case 4: xl = 3*2^30 - 1
        xl = 32'd35;
        #10;
        $display("Test Case 4: xl = 3*2^30 - 1, xln = %h", xln);

        // Finish simulation
        $finish;
    end

endmodule
