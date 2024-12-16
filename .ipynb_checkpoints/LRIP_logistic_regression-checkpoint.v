`timescale 1 ns / 1 ps

module LRIP_v1_0_logistic_regression #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4,
    parameter integer BRAM_DEPTH = 64      // Depth of the BRAM
)
(
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire S_AXI_AWVALID,
    output wire S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output wire S_AXI_WREADY,
    output wire [1 : 0] S_AXI_BRESP,
    output wire S_AXI_BVALID,
    input wire S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire S_AXI_ARVALID,
    output wire S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire S_AXI_RVALID,
    input wire S_AXI_RREADY
);

    // AXI protocol signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg axi_awready;
    reg axi_wready;
    reg [1 : 0] axi_bresp;
    reg axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [1 : 0] axi_rresp;
    reg axi_rvalid;

    // BRAM storage for weights and biases
    reg signed [C_S_AXI_DATA_WIDTH-1 : 0] bram_weights [0:BRAM_DEPTH-1];
    reg signed [C_S_AXI_DATA_WIDTH-1 : 0] bram_biases [0:BRAM_DEPTH-1];

    // Logistic regression internal signals
    reg signed [C_S_AXI_DATA_WIDTH-1 : 0] feature0, feature1;
    reg signed [C_S_AXI_DATA_WIDTH-1 : 0] weight0, weight1, bias;
    reg signed [C_S_AXI_DATA_WIDTH-1 : 0] linear_comb;
    reg result;

    // Connect output ports to internal signals
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA = {31'b0, result}; // Return only result as output for simplicity
    assign S_AXI_RRESP = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;

    // AXI write logic (handle writes to BRAM)
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            // Reset logic
            axi_awready <= 0;
            axi_wready <= 0;
            axi_bvalid <= 0;
            axi_bresp <= 2'b0;
            axi_arready <= 0;
            axi_rvalid <= 0;
            axi_rresp <= 2'b0;
        end else begin
            // Handle AXI write transactions
            if (S_AXI_AWVALID && !axi_awready) begin
                axi_awaddr <= S_AXI_AWADDR;
                axi_awready <= 1;
            end else if (S_AXI_WVALID && axi_awready) begin
                if (axi_awaddr == 0) feature0 <= S_AXI_WDATA;
                if (axi_awaddr == 1) feature1 <= S_AXI_WDATA;
                if (axi_awaddr == 2) weight0 <= S_AXI_WDATA;
                if (axi_awaddr == 3) weight1 <= S_AXI_WDATA;
                if (axi_awaddr == 4) bias <= S_AXI_WDATA;
                
                axi_wready <= 1;
                axi_bvalid <= 1;
                axi_bresp <= 2'b0;  // OKAY response
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 0;
                axi_awready <= 0;
                axi_wready <= 0;
            end

            // Handle AXI read transactions
            if (S_AXI_ARVALID && !axi_arready) begin
                axi_araddr <= S_AXI_ARADDR;
                axi_arready <= 1;
            end else if (axi_arready && !axi_rvalid) begin
                // Read from specific address in BRAM
                if (axi_araddr == 0) axi_rdata <= feature0;
                if (axi_araddr == 1) axi_rdata <= feature1;
                if (axi_araddr == 2) axi_rdata <= weight0;
                if (axi_araddr == 3) axi_rdata <= weight1;
                if (axi_araddr == 4) axi_rdata <= bias;

                axi_rvalid <= 1;
                axi_rresp <= 2'b0;  // OKAY response
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 0;
                axi_arready <= 0;
            end
        end
    end

    // Logistic regression calculation
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            result <= 0;
        end else begin
            linear_comb = (weight0 * feature0 + weight1 * feature1 + bias);
            result <= (linear_comb > 0) ? 1 : 0;  // Logistic regression with threshold
        end
    end

endmodule
