module axi4_lite_gpu #(
    parameter AXI_ADDRESS_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter FBUF_ADDR_WIDTH = 19,
    parameter FBUF_DATA_WIDTH = 8
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

reg read_transaction_ok;

// Store read address and do handshake
reg [AXI_ADDRESS_WIDTH - 1 : 0] read_address;
reg read_address_ok;
reg s_axi_ctrl_arready_int;

assign s_axi_ctrl_arready = !s_axi_ctrl_aresetn ? 0 : s_axi_ctrl_arready_int;

always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        read_address <= 0;
        read_address_ok <= 0;
        s_axi_ctrl_arready_int <= 0;
    end else begin
        if (read_transaction_ok) begin
            read_address <= 0;
            read_address_ok <= 0;
            s_axi_ctrl_arready_int <= 0;
        end else if (s_axi_ctrl_arvalid && (!read_address_ok || read_transaction_ok)) begin
            read_address <= s_axi_ctrl_awaddr;
            read_address_ok <= 1;
            s_axi_ctrl_arready_int <= 1;
        end else begin
            s_axi_ctrl_arready_int <= 0;
        end
    end
end

// Handle read event
reg [AXI_DATA_WIDTH - 1 : 0] read_data;
reg read_data_ok;
reg [1:0] read_resp;

reg read_processing_start;
reg read_processing_done;

assign s_axi_ctrl_rvalid = !s_axi_ctrl_aresetn ? 0 : read_data_ok;
assign s_axi_ctrl_rdata = !s_axi_ctrl_aresetn ? 0 : read_data;
assign s_axi_ctrl_rresp = !s_axi_ctrl_aresetn ? 0 : read_resp;

always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        read_data <= 0;
        read_resp <= 0;
        read_data_ok <= 0;
        // Simulate processing
        read_processing_done <= 0;
    end else begin
        if (read_transaction_ok) begin
            read_data <= 0;
            read_resp <= 0;
            read_data_ok <= 0;
        end else if (read_address_ok) begin
            if (read_processing_done) begin
                read_processing_start <= 0;
                read_data <= 32'hffffffff;
                read_resp <= RESP_OKAY;
                read_data_ok <= 1;
                // Simulate
                read_processing_done <= 0;
            end else if (!read_processing_start) begin
                // TODO process read request and respond accordingly
                read_processing_start <= 1;
                // Simulate processing
                read_processing_done <= 1;
            end else begin
                read_processing_start <= 0;
            end
        end
    end
end

// Mark read transaction as OK for one clock cycle when read data channel is ready
always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        read_transaction_ok <= 0;
    end else begin
        if (read_data_ok && s_axi_ctrl_rready) begin
            read_transaction_ok <= 1;
        end else begin
            read_transaction_ok <= 0;
        end
    end
end



reg write_transaction_ok;

// Store write address and do handshake
reg [AXI_ADDRESS_WIDTH - 1 : 0] write_address;
reg write_address_ok;
reg s_axi_ctrl_awready_int;

assign s_axi_ctrl_awready = !s_axi_ctrl_aresetn ? 0 : s_axi_ctrl_awready_int;

always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        write_address <= 0;
        write_address_ok <= 0;
        s_axi_ctrl_awready_int <= 0;
    end else begin
        if (write_transaction_ok) begin
            write_address <= 0;
            write_address_ok <= 0;
            s_axi_ctrl_awready_int <= 0;
        end else if (s_axi_ctrl_awvalid && (!write_address_ok || write_transaction_ok)) begin
            write_address <= s_axi_ctrl_awaddr;
            write_address_ok <= 1;
            s_axi_ctrl_awready_int <= 1;
        end else begin
            s_axi_ctrl_awready_int <= 0;
        end
    end
end


// Store write data and do handshake
reg [AXI_DATA_WIDTH - 1 : 0] write_data;
reg write_data_ok;
reg s_axi_ctrl_wready_int;

assign s_axi_ctrl_wready = !s_axi_ctrl_aresetn ? 0 : s_axi_ctrl_wready_int;

always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        write_data <= 0;
        write_data_ok <= 0;
        s_axi_ctrl_wready_int <= 0;
    end else begin
        if (write_transaction_ok) begin
            write_data <= 0;
            write_data_ok <= 0;
            s_axi_ctrl_wready_int <= 0;
        end if (s_axi_ctrl_wvalid && (!write_data_ok || write_transaction_ok)) begin
            write_data <= s_axi_ctrl_wdata;
            write_data_ok <= 1;
            s_axi_ctrl_wready_int <= 1;
        end else begin
            s_axi_ctrl_wready_int <= 0;
        end
    end
end

reg [1:0] write_response;
reg write_response_ok;
reg write_processing_start;
reg write_processing_done;

assign s_axi_ctrl_bresp = !s_axi_ctrl_aresetn ? 2'b00 : write_response;
assign s_axi_ctrl_bvalid = !s_axi_ctrl_aresetn ? 0 : write_response_ok;

// Handle write event when both write address & data channel handshake is done
always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        write_response <= 2'b00;
        write_response_ok <= 0;
        write_processing_start <= 0;
        // Simulate
        write_processing_done <= 0;
    end else begin
        if (write_transaction_ok) begin
            write_response <= 2'b00;
            write_response_ok <= 0;
        end else if (write_address_ok && write_data_ok) begin
            if (write_processing_done) begin
                write_response <= RESP_OKAY;
                write_response_ok <= 1;
                write_processing_start <= 0;
                // Simulate
                write_processing_done <= 0;
            end else if (!write_processing_start) begin
                // TODO process data and respond accordingly
                write_processing_start <= 1;
                // Simulate processing
                write_processing_done <= 1;
            end else begin
                write_processing_start <= 0;
            end
        end
    end
end

// Mark write transaction as OK for one clock cycle when write response channel is ready
always @(posedge s_axi_ctrl_aclk) begin
    if (!s_axi_ctrl_aresetn) begin
        write_transaction_ok <= 0;
    end else begin
        if (write_response_ok && s_axi_ctrl_bready) begin
            write_transaction_ok <= 1;
        end else begin
            write_transaction_ok <= 0;
        end
    end
end


// During reset all xVALID signals must be LOW

endmodule
