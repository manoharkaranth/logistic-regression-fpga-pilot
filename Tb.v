`timescale 1ns/1ps
module logistic_regression_tb();

    reg clk;
    reg reset;
    reg read_enable;
    reg [31:0] feature0, feature1;
    wire [31:0] result;

    logistic_regression uut (
        .clk(clk),
        .reset(reset),
        .read_enable(read_enable),
        .feature0(feature0),
        .feature1(feature1),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        // Initialize signals
        reset = 1;
        read_enable = 0;
        feature0 = 32'd12;  // Equivalent to 12
        feature1 = 32'd8;   // Equivalent to 08

        #10; // Wait for reset to complete
        reset = 0; // Release reset
        read_enable = 1; // Enable reading from BRAM

        #10; // Wait for result to compute

        // Display result
        $display("Result: %d", result);
        $finish;
    end
endmodule
