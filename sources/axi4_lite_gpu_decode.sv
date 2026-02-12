module axi4_lite_gpu_decode #(
    parameter FRAME_WIDTH_SCALED = 640,
    parameter FRAME_HEIGHT_SCALED = 480,
    parameter ADDRESS_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter FBUF_ADDR_WIDTH = 19,
    parameter FBUF_DATA_WIDTH = 8
) (
    // AXI Clock
    input clk,
    input rst_n,
    // Read data channel
    input read_processing_start,
    input [ADDRESS_WIDTH - 1 : 0] read_address,
    output [DATA_WIDTH - 1 : 0] read_data,
    output read_processing_done,
    output read_resp_ok,
    // Write data channel
    input write_processing_start,
    input [ADDRESS_WIDTH - 1 : 0] write_address,
    input [DATA_WIDTH - 1 : 0] write_data,
    output write_processing_ok,
    output write_processing_done,
    // Framebuffer BRAM connection (write only)
    input fbuf_rst_busy,
    output fbuf_en_wr,
    output fbuf_wrea,
    output [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr,
    output [FBUF_DATA_WIDTH - 1 : 0] fbuf_data,
    output fbuf_rst_req_n
);

reg read_processing_done_reg;
reg [DATA_WIDTH - 1 : 0] read_data_reg;
reg read_resp_ok_reg;

reg write_processing_ok_reg;
reg write_processing_done_reg;

reg fbuf_en_wr_reg;
reg fbuf_wrea_reg;
reg [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr_reg;
reg [FBUF_DATA_WIDTH - 1 : 0] fbuf_data_reg;
reg fbuf_rst_req_n_reg;

assign read_processing_done = !rst_n ? 0 : read_processing_done_reg;
assign read_data = !rst_n ? 0 : read_data_reg;
assign read_resp_ok = !rst_n ? 0 : read_resp_ok_reg;

assign write_processing_ok = !rst_n ? 0 : write_processing_ok_reg;
assign write_processing_done = !rst_n ? 0 : write_processing_done_reg;

assign fbuf_en_wr = !rst_n ? 0 : fbuf_en_wr_reg;
assign fbuf_wrea = !rst_n ? 0 : fbuf_wrea_reg;
assign fbuf_addr = !rst_n ? 0 : fbuf_addr_reg;
assign fbuf_data = !rst_n ? 0 : fbuf_data_reg;

assign fbuf_rst_req_n = !rst_n ? 0 : fbuf_rst_req_n_reg; // Reset framebuffer on system reset

always @(posedge clk) begin
    if (!rst_n) begin
        read_processing_done_reg <= 0;
        read_data_reg <= 0;
        read_resp_ok_reg <= 0;
    end else begin
        if (read_processing_start) begin
            // Use 0x00 as status register
            if (read_address == 0) begin
                read_data_reg <= {27'h0, fbuf_rst_busy, read_processing_start, read_processing_done_reg, write_processing_start, write_processing_done};
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
        // Default state, should set everything to 0, except framebuffer reset request
        fbuf_rst_req_n_reg <= 1;
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
            if (write_address == 32'h0) begin
                // Do a single pixel write (max 4096x4096@8bit)
                fbuf_rst_req_n_reg <= 1;
                fbuf_en_wr_reg <= 1;
                fbuf_wrea_reg <= 1;
                fbuf_data_reg <= write_data[FBUF_DATA_WIDTH - 1 : 0];
                fbuf_addr_reg <= write_data[31:20] + write_data[19:8] * FRAME_WIDTH_SCALED;
            end else if (write_address == 32'h4) begin
                // Reset request, set other regs to 0
                fbuf_rst_req_n_reg <= write_data == 0; // Only reset if data is non-zero
                fbuf_en_wr_reg <= 0;
                fbuf_wrea_reg <= 0;
                fbuf_addr_reg <= 0;
                fbuf_data_reg <= 0;
            end else begin
                // Default state, should set everything to 0, except reset request
                fbuf_rst_req_n_reg <= 1;
                fbuf_en_wr_reg <= 0;
                fbuf_wrea_reg <= 0;
                fbuf_addr_reg <= 0;
                fbuf_data_reg <= 0;
            end
        end else begin
            // Default state, should set everything to 0, except reset request
            fbuf_rst_req_n_reg <= 1;
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