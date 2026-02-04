module tb_axi4_lite_gpu;

localparam AXI_ADDRESS_WIDTH = 32;
localparam AXI_DATA_WIDTH = 32;
localparam FBUF_ADDR_WIDTH = 19;
localparam FBUF_DATA_WIDTH = 8;

logic clk = 0;
logic rst_n = 0;

// Read address channel
logic [AXI_ADDRESS_WIDTH - 1 : 0] s_axi_ctrl_araddr;
logic s_axi_ctrl_arvalid;
logic s_axi_ctrl_arready;
// Read data channel
logic [AXI_DATA_WIDTH - 1 : 0] s_axi_ctrl_rdata;
logic [1:0] s_axi_ctrl_rresp;
logic s_axi_ctrl_rvalid;
logic s_axi_ctrl_rready;
// Write address channel
logic [AXI_ADDRESS_WIDTH - 1 : 0] s_axi_ctrl_awaddr;
logic s_axi_ctrl_awvalid;
logic s_axi_ctrl_awready;
// Write data channel
logic [AXI_DATA_WIDTH - 1 : 0] s_axi_ctrl_wdata;
logic s_axi_ctrl_wvalid;
logic s_axi_ctrl_wready;
// Write response channel
logic [1:0] s_axi_ctrl_bresp;
logic s_axi_ctrl_bvalid;
logic s_axi_ctrl_bready;

// Framebuffer BRAM connection (write only)
logic fbuf_en_wr;
logic fbuf_wrea;
logic [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr;
logic [FBUF_DATA_WIDTH - 1 : 0] fbuf_data;
logic fbuf_rst_req_n;

axi4_lite_gpu #(
    .AXI_ADDRESS_WIDTH(AXI_ADDRESS_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .FBUF_ADDR_WIDTH(FBUF_ADDR_WIDTH),
    .FBUF_DATA_WIDTH(FBUF_DATA_WIDTH)
) axi4_lite_gpu_inst(
    .s_axi_ctrl_aclk(clk),
    .s_axi_ctrl_aresetn(rst_n),
    // Read address channel
    .s_axi_ctrl_araddr(s_axi_ctrl_araddr),
    .s_axi_ctrl_arvalid(s_axi_ctrl_arvalid),
    .s_axi_ctrl_arready(s_axi_ctrl_arready),
    // Read data channel
    .s_axi_ctrl_rdata(s_axi_ctrl_rdata),
    .s_axi_ctrl_rresp(s_axi_ctrl_rresp),
    .s_axi_ctrl_rvalid(s_axi_ctrl_rvalid),
    .s_axi_ctrl_rready(s_axi_ctrl_rready),
    // Write address channel
    .s_axi_ctrl_awaddr(s_axi_ctrl_awaddr),
    .s_axi_ctrl_awvalid(s_axi_ctrl_awvalid),
    .s_axi_ctrl_awready(s_axi_ctrl_awready),
    // Write data channel
    .s_axi_ctrl_wdata(s_axi_ctrl_wdata),
    .s_axi_ctrl_wvalid(s_axi_ctrl_wvalid),
    .s_axi_ctrl_wready(s_axi_ctrl_wready),
    // Write response channel
    .s_axi_ctrl_bresp(s_axi_ctrl_bresp),
    .s_axi_ctrl_bvalid(s_axi_ctrl_bvalid),
    .s_axi_ctrl_bready(s_axi_ctrl_bready),
    // Framebuffer connections
    .fbuf_en_wr(fbuf_en_wr),
    .fbuf_wrea(fbuf_wrea),
    .fbuf_addr(fbuf_addr),
    .fbuf_data(fbuf_data),
    .fbuf_rst_req_n(fbuf_rst_req_n)
);

always #5 clk = ~clk;

// always @(posedge clk) begin
//     if (!rst_n) begin
//         assert(!s_axi_ctrl_rvalid && !s_axi_ctrl_bvalid) else $error("All xVALID signals MUST be LOW during reset");
//     end
// end
//assert property (@(posedge clk) !rst_n |-> !s_axi_ctrl_rvalid && !s_axi_ctrl_bvalid);

// always @(posedge clk) begin
//     if (!rst_n) begin
//         if (!(!s_axi_ctrl_arready && !s_axi_ctrl_awready && !s_axi_ctrl_wready)) begin
//             $error("All xVALID signals SHOULD be LOW during reset");
//         end
//     end
// end
//assert property (@(posedge clk) !rst_n |-> !s_axi_ctrl_arready && !s_axi_ctrl_awready && !s_axi_ctrl_wready) else $error("All xVALID signals SHOULD be LOW during reset");

initial begin
    rst_n = 0;
    #100
    rst_n = 1;
    #10
    $display("Starting read test...");
    s_axi_ctrl_araddr = 32'h01;
    s_axi_ctrl_arvalid = 1;
    #10
    assert(s_axi_ctrl_arready) else $error("ARREADY MUST be HIGH after one clock cycle of ARVALID");
    s_axi_ctrl_arvalid = 0;
    s_axi_ctrl_araddr = 32'h00;
    #80 // TODO: Modify according to expected behaviour
    assert(s_axi_ctrl_rvalid) else $error("RVALID MUST be HIGH");
    assert(s_axi_ctrl_rresp == 2'b00) else $error("RRESP MUST be 2'b00 (RESP_OKAY)");
    assert(s_axi_ctrl_rdata == 32'hffffffff) else $error("RRESP MUST be 32'hffffffff");
    s_axi_ctrl_rready = 1;
    #10
    assert(!s_axi_ctrl_rvalid) else $error("RVALID MUST be LOW");
    #10
    $display("Starting write test...");
    s_axi_ctrl_awvalid = 1;
    s_axi_ctrl_awaddr = 32'h00;
    #10
    assert(s_axi_ctrl_awready) else $error("AWREADY MUST be HIGH after one clock cycle of AWVALID");
    s_axi_ctrl_awvalid = 0;
    s_axi_ctrl_awaddr = 32'h00;
    s_axi_ctrl_wvalid = 1;
    s_axi_ctrl_wdata = 32'b00000000011110000000111111100011;
    #10
    assert(s_axi_ctrl_wready) else $error("WREADY MUST be HIGH after one clock cycle of WVALID");
    s_axi_ctrl_wvalid = 0;
    s_axi_ctrl_wdata = 32'h00;
    #80 // TODO: Modify according to expected behaviour
    assert(s_axi_ctrl_bvalid) else $error("BVALID MUST be HIGH");
    assert(s_axi_ctrl_bresp == 2'b00) else $error("BRESP MUST be 2'b00 (RESP_OKAY)");
    s_axi_ctrl_bready = 1;
    #10
    assert(!s_axi_ctrl_bvalid) else $error("BVALID MUST be LOW");
    rst_n = 1;
    #10
    $display("Basic read and write test finished");
    $finish;
end

endmodule