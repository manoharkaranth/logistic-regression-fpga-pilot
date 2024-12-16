`timescale 1ns/1ps

module logistic_regression(
    input wire clk,
    input wire reset,
    input wire [3:0] address, // Address input for BRAM
    input wire read_enable,     // Control signal to read from BRAM
    input wire signed [31:0] feature0,
    input wire signed [31:0] feature1,
    output reg signed [31:0] result
);

reg signed [31:0] linear_comb;
real sigmoid;

// Block RAM for weights and bias
reg signed [31:0] bram [0:2]; // 3 entries: weight0, weight1, bias

// Initialize BRAM with weights and bias
initial begin
    bram[0] = 32'd5;    // weight0
    bram[1] = -32'd3;   // weight1
    bram[2] = 32'd1;    // bias
end

// Calculate linear combination when read_enable is asserted
always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 32'd0; // Reset result
    end else if (read_enable) begin
        // Read weights and bias from BRAM using address
        linear_comb = (bram[0] * feature0 + bram[1] * feature1 + bram[2]);

        // Approximate sigmoid for simplicity
        if (linear_comb > 0) begin
            result <= 32'd1;  // Approximation of sigmoid for positive values
        end else begin
            result <= 32'd0;  // Approximation for negative values
        end
    end
end

endmodule
