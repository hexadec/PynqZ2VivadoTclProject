module axi4_lite_gpu_command_handler #(
    parameter AXI_ADDRESS_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter FBUF_ADDR_WIDTH = 19,
    parameter FBUF_DATA_WIDTH = 8
) (
    // AXI Clock
    input clk,
    input rst_n,
    // Read data channel
    input read_processing_start,
    input [AXI_ADDRESS_WIDTH - 1 : 0] read_address,
    output [AXI_DATA_WIDTH - 1 : 0] read_data,
    output read_processing_done,
    output read_resp_ok,
    // Write data channel
    input write_processing_start,
    input [AXI_ADDRESS_WIDTH - 1 : 0] write_address,
    input [AXI_DATA_WIDTH - 1 : 0] write_data,
    output write_processing_ok,
    output write_processing_done,
    // Framebuffer BRAM connection (write only)
    output fbuf_en_wr,
    output fbuf_wrea,
    output [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr,
    output [FBUF_DATA_WIDTH - 1 : 0] fbuf_data
);

reg read_processing_done_reg;
reg [AXI_DATA_WIDTH - 1 : 0] read_data_reg;
reg read_resp_ok_reg;

reg write_processing_ok_reg;
reg write_processing_done_reg;

reg fbuf_en_wr_reg;
reg fbuf_wrea_reg;
reg [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr_reg;
reg [FBUF_DATA_WIDTH - 1 : 0] fbuf_data_reg;

assign read_processing_done = !rst_n ? 0 : read_processing_done_reg;
assign read_data = !rst_n ? 0 : read_data_reg;
assign read_resp_ok = !rst_n ? 0 : read_resp_ok_reg;

assign write_processing_ok = !rst_n ? 0 : write_processing_ok_reg;
assign write_processing_done = !rst_n ? 0 : write_processing_done_reg;

assign fbuf_en_wr = !rst_n ? 0 : fbuf_en_wr_reg;
assign fbuf_wrea = !rst_n ? 0 : fbuf_wrea_reg;
assign fbuf_addr = !rst_n ? 0 : fbuf_addr_reg;
assign fbuf_data = !rst_n ? 0 : fbuf_data_reg;

always @(posedge clk) begin
    if (!rst_n) begin
        read_processing_done_reg <= 0;
        read_data_reg <= 0;
        read_resp_ok_reg <= 0;
    end else begin
        if (read_processing_start) begin
            // Use 0x00 as status register
            if (read_address == 0) begin
                read_data_reg <= {28'h0, read_processing_start, read_processing_done_reg, write_processing_start, write_processing_done};
                read_processing_done_reg <= 1;
                read_resp_ok_reg <= 1;
            end else begin
                // TODO
                read_data_reg <= 32'hffffffff;
                read_processing_done_reg <= 1;
                read_resp_ok_reg <= 0;
            end
        end else begin
            read_processing_done_reg <= 0;
            read_data_reg <= 0;
            read_resp_ok_reg <= 0;
        end
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        write_processing_ok_reg <= 0;
        write_processing_done_reg <= 0;
        fbuf_en_wr_reg <= 0;
        fbuf_wrea_reg <= 0;
        fbuf_addr_reg <= 0;
        fbuf_data_reg <= 0;
    end else begin
        if (write_processing_start) begin
            write_processing_ok_reg <= 1;
            write_processing_done_reg <= 1;
            fbuf_en_wr_reg <= 1;
            fbuf_wrea_reg <= 1;
            fbuf_addr_reg <= write_address[FBUF_ADDR_WIDTH - 1 : 0];
            fbuf_data_reg <= write_data[FBUF_DATA_WIDTH - 1 : 0];
        end else begin
            write_processing_ok_reg <= 0;
            write_processing_done_reg <= 0;
            fbuf_en_wr_reg <= 0;
            fbuf_wrea_reg <= 0;
            fbuf_addr_reg <= 0;
            fbuf_data_reg <= 0;
        end
    end
end
endmodule