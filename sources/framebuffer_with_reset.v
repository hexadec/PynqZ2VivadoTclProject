module framebuffer_with_reset #(
    parameter FRAME_WIDTH = 640,
    parameter FRAME_HEIGHT = 480,
    parameter SCALING_FACTOR = 1,
    parameter ADDR_WIDTH = 19,
    parameter DATA_WIDTH = 8
    ) (
    input rst_req_n,
    input clk_wr, clk_rd, en_wr, en_rd, wrea,
    input [ADDR_WIDTH - 1:0] addr_rd, addr_wr,
    input [DATA_WIDTH - 1:0] din, 
    output rst_busy,
    output reg [DATA_WIDTH - 1:0] dout
    );

    localparam NUMBER_OF_PIXELS = FRAME_WIDTH / SCALING_FACTOR * FRAME_HEIGHT / SCALING_FACTOR;

reg [ADDR_WIDTH - 1 : 0] reset_counter;

wire en_wr_int;
wire wrea_int;
wire addr_wr_int;
wire [DATA_WIDTH - 1:0] din_int;

framebuffer #(
    .FRAME_WIDTH(FRAME_WIDTH),
    .FRAME_HEIGHT(FRAME_HEIGHT),
    .SCALING_FACTOR(SCALING_FACTOR),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) framebuffer_inst (
    .clk_wr(clk_wr),
    .clk_rd(clk_rd),
    .en_rd(en_rd),
    .addr_rd(addr_rd),
    .dout(dout),
    .en_wr(en_wr_int),
    .wrea(wrea_int),
    .addr_wr(addr_wr_int),
    .din(din_int)
);

assign rst_busy = reset_counter != 0 || !rst_req_n;
assign en_wr_int = rst_busy ? 1 : en_wr;
assign wrea_int = rst_busy ? 1 : wrea;
assign addr_wr_int = rst_busy ? reset_counter : addr_wr;
assign din_int = rst_busy ? 0 : din;

always @(posedge clk_wr) begin
    if (!rst_req_n) begin
        reset_counter <= 1; // NOT A drawback: if rst_req_n is asserted while reset_counter has not finished, addr 0 is skipped
    end else if (reset_counter < NUMBER_OF_PIXELS - 1) begin
        reset_counter <= reset_counter + 1;
    end else begin
        reset_counter <= 0;
    end
end

endmodule