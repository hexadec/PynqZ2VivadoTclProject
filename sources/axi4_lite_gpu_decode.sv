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
    output reg fbuf_en_wr,
    output reg fbuf_wrea,
    output reg [FBUF_ADDR_WIDTH - 1 : 0] fbuf_addr,
    output reg [FBUF_DATA_WIDTH - 1 : 0] fbuf_data,
    output reg fbuf_rst_req_n
);

reg read_processing_done_reg;
reg [DATA_WIDTH - 1 : 0] read_data_reg;
reg read_resp_ok_reg;

reg [ADDRESS_WIDTH - 1 : 0] write_addr_reg;
reg [DATA_WIDTH - 1 : 0] write_data_reg;

assign read_processing_done = !rst_n ? 0 : read_processing_done_reg;
assign read_data = !rst_n ? 0 : read_data_reg;
assign read_resp_ok = !rst_n ? 0 : read_resp_ok_reg;

wire rect_start;
wire rect_busy;
wire rect_done;
wire rect_err;

wire rect_left_valid, rect_right_valid;
wire [11:0] rect_left_x, rect_left_y, rect_right_x, rect_right_y;
wire rect_color_valid;
wire [7:0] rect_color;

wire rect_fbuf_en_wr;
wire rect_fbuf_wrea;
wire [FBUF_ADDR_WIDTH - 1 : 0] rect_fbuf_addr;
wire [FBUF_DATA_WIDTH - 1 : 0] rect_fbuf_data;

axi4_lite_gpu_execute_rect #(
    .FRAME_WIDTH_SCALED(FRAME_WIDTH_SCALED),
    .FRAME_HEIGHT_SCALED(FRAME_HEIGHT_SCALED),
    .COLOR_WIDTH(8),
    .FBUF_ADDR_WIDTH(FBUF_ADDR_WIDTH),
    .FBUF_DATA_WIDTH(FBUF_DATA_WIDTH)
) axi4_lite_gpu_execute_rect_inst (
    .clk(clk),
    .rst_n(rst_n),

    .start(rect_start),
    .busy(rect_busy),
    .done(rect_done),
    .err(rect_err),

    .left_valid(rect_left_valid),
    .left_x(rect_left_x),
    .left_y(rect_left_y),
    .right_valid(rect_right_valid),
    .right_x(rect_right_x),
    .right_y(rect_right_y),
    .color_valid(rect_color_valid),
    .color(rect_color),

    .fbuf_en_wr(rect_fbuf_en_wr),
    .fbuf_wrea(rect_fbuf_wrea),
    .fbuf_addr(rect_fbuf_addr),
    .fbuf_data(rect_fbuf_data)
);

enum reg [3:0] {IDLE = 0, BUSY_SINGLE, BUSY_RESET, BUSY_RECT, LOAD_RECT_COORDS_LEFT, LOAD_RECT_COORDS_RIGHT, LOAD_RECT_COLOR} execute_unit_state, next_state;

assign write_processing_ok = !rst_n ? 0 : (execute_unit_state == IDLE && write_processing_start) ? 1 : 0;
assign write_processing_done = !rst_n ? 0 : (execute_unit_state == IDLE && write_processing_start) ? 1 : 0;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        execute_unit_state <= IDLE;
    end else begin
        execute_unit_state <= next_state;
    end
end

always_comb begin
    if (!rst_n) begin
        next_state = IDLE;
    end else begin
        next_state = IDLE;
        case (execute_unit_state)
            IDLE: begin
                if (write_processing_start) begin
                    case (write_address)
                        32'h00:
                            next_state = BUSY_SINGLE;
                        32'h04:
                            next_state = BUSY_RESET;
                        32'h100:
                            next_state = BUSY_RECT;
                        32'h104:
                            next_state = LOAD_RECT_COORDS_LEFT;
                        32'h108:
                            next_state = LOAD_RECT_COORDS_RIGHT;
                        32'h10C:
                            next_state = LOAD_RECT_COLOR;
                    endcase
                end
            end
            BUSY_RESET:
                if (fbuf_rst_busy) begin
                    next_state = BUSY_RESET;
                end
            BUSY_RECT:
                if ((rect_busy || rect_start) && !rect_done && !rect_err) begin
                    next_state = BUSY_RECT;
                end
        endcase
    end
end


assign rect_left_valid = (execute_unit_state == LOAD_RECT_COORDS_LEFT);
assign rect_right_valid = (execute_unit_state == LOAD_RECT_COORDS_RIGHT);
assign rect_left_x = write_data_reg[27:16];
assign rect_left_y = write_data_reg[11:0];
assign rect_right_x = write_data_reg[27:16];
assign rect_right_y = write_data_reg[11:0];

assign rect_color_valid = (execute_unit_state == LOAD_RECT_COLOR);
assign rect_color = write_data_reg[7:0];

assign rect_start = (execute_unit_state == BUSY_RECT) && !rect_busy && !rect_done && !rect_err;

always_comb begin
    case (execute_unit_state)
        BUSY_RESET: begin
            fbuf_rst_req_n = write_data_reg == 0; // Only reset if data is non-zero
            fbuf_en_wr = 0;
            fbuf_wrea = 0;
            fbuf_addr = 0;
            fbuf_data = 0;
        end
        BUSY_SINGLE: begin
            fbuf_rst_req_n = 1;
            fbuf_en_wr = 1;
            fbuf_wrea = 1;
            fbuf_data = write_data_reg[7:0];
            fbuf_addr = write_data_reg[31:20] + write_data_reg[19:8] * FRAME_WIDTH_SCALED;
        end
        BUSY_RECT: begin
            fbuf_rst_req_n = 1;
            fbuf_en_wr = rect_fbuf_en_wr;
            fbuf_wrea = rect_fbuf_wrea;
            fbuf_addr = rect_fbuf_addr;
            fbuf_data = rect_fbuf_data;
        end
        default: begin
            fbuf_rst_req_n = 1;
            fbuf_en_wr = 0;
            fbuf_wrea = 0;
            fbuf_addr = 0;
            fbuf_data = 0;
        end
    endcase
end


always_ff @(posedge clk) begin
    if (!rst_n) begin
        read_processing_done_reg <= 0;
        read_data_reg <= 0;
        read_resp_ok_reg <= 0;
    end else begin
        if (read_processing_start) begin
            if (read_address == 32'h0) begin // Use 0x00 as status register
                read_data_reg <= {27'h0, fbuf_rst_busy, read_processing_start, read_processing_done_reg, write_processing_start, write_processing_done};
                read_processing_done_reg <= 1;
                read_resp_ok_reg <= 1;
            end else if (read_address == 32'h4) begin // Use 0x04 as state register
                read_data_reg <= execute_unit_state;
                read_processing_done_reg <= 1;
                read_resp_ok_reg <= 1;
            end else if (read_address == 32'h8) begin // Use 0x08 as resolution query register
                read_data_reg[15:0] <= FRAME_WIDTH_SCALED;
                read_data_reg[31:16] <= FRAME_HEIGHT_SCALED;
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

always_ff @(posedge clk) begin
    if (!rst_n) begin
        write_addr_reg <= 0;
        write_data_reg <= 0;
    end else begin
        if (write_processing_start && execute_unit_state == IDLE) begin
            write_addr_reg <= write_address;
            write_data_reg <= write_data;
        end
    end
end

endmodule
