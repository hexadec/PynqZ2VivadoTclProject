module axi4_lite_gpu #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    // AXI global signals
    input s_axi_ctrl_aclk,
    input s_axi_ctrl_aresetn,
    // Read address channel
    input [ADDRESS_WIDTH - 1 : 0] s_axi_ctrl_araddr,
    input s_axi_ctrl_arvalid,
    output s_axi_ctrl_arready,
    // Read data channel
    output [DATA_WIDTH - 1 : 0] s_axi_ctrl_rdata,
    output [1:0] s_axi_ctrl_rresp,
    output s_axi_ctrl_rvalid,
    input s_axi_ctrl_rready,
    // Write address channel
    input [ADDRESS_WIDTH - 1 : 0] s_axi_ctrl_awaddr,
    input s_axi_ctrl_awvalid,
    output s_axi_ctrl_awready,
    // Write data channel
    input [DATA_WIDTH - 1 : 0] s_axi_ctrl_wdata,
    input s_axi_ctrl_wvalid,
    output s_axi_ctrl_wready,
    // Write response channel
    output [1:0] s_axi_ctrl_bresp,
    output s_axi_ctrl_bvalid,
    input s_axi_ctrl_bready

);

// During reset all xVALID signals must be LOW

endmodule