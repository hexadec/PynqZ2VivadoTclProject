module axi4_lite_gpu #(
    parameter AXI_ADDRESS_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter FBUF_ADDR_WIDTH = 17,
    parameter FBUF_DATA_WIDTH = 12
) (
    // AXI global signals
    input s_axi_ctrl_aclk,
    input s_axi_ctrl_aresetn,
    // Read address channel
    input [AXI_ADDRESS_WIDTH - 1 : 0] s_axi_ctrl_araddr,
    input s_axi_ctrl_arvalid,
    output s_axi_ctrl_arready,
    // Read data channel
    output [AXI_DATA_WIDTH - 1 : 0] s_axi_ctrl_rdata,
    output [1:0] s_axi_ctrl_rresp,
    output s_axi_ctrl_rvalid,
    input s_axi_ctrl_rready,
    // Write address channel
    input [AXI_ADDRESS_WIDTH - 1 : 0] s_axi_ctrl_awaddr,
    input s_axi_ctrl_awvalid,
    output s_axi_ctrl_awready,
    // Write data channel
    input [AXI_DATA_WIDTH - 1 : 0] s_axi_ctrl_wdata,
    input s_axi_ctrl_wvalid,
    output s_axi_ctrl_wready,
    // Write response channel
    output [1:0] s_axi_ctrl_bresp,
    output s_axi_ctrl_bvalid,
    input s_axi_ctrl_bready,

    // Framebuffer BRAM connection (write only)
    output fbuf_en_wr,
    output fbuf_wrea,
    output [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr,
    output [FBUF_DATA_WIDTH - 1 : 0] fbuf_data
);

localparam RESP_OKAY = 2'b00;
localparam RESP_SLVERR = 2'b10;

// During reset all xVALID signals must be LOW

endmodule
