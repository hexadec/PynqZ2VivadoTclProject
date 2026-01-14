module tb_test_pattern_generator;

localparam FBUF_ADDR_WIDTH = 16;
localparam FBUF_DATA_WIDTH = 8;

logic clk = 0;
logic rst_n = 0;
logic [FBUF_ADDR_WIDTH - 1 : 0] fbuf_address;
logic [FBUF_DATA_WIDTH - 1 : 0] fbuf_color;
logic fbuf_wr_en;

always #5 clk = ~clk; //create clk with 100 MHz

test_pattern_generator #(
    .FRAME_WIDTH(160),
    .FRAME_HEIGHT(120),
    .SCALING_FACTOR(4),
    .FBUF_ADDR_WIDTH(FBUF_ADDR_WIDTH),
    .FBUF_DATA_WIDTH(FBUF_DATA_WIDTH)
) tpg_instance (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_fbuf_address(fbuf_address),
    .pixel_fbuf_color(fbuf_color),
    .pixel_fbuf_wr_en(fbuf_wr_en)
);

initial begin
    #10
    assert(fbuf_address == 0);
    assert(fbuf_color == 0);
    assert(fbuf_wr_en == 0);
    rst_n = 1;
    repeat(1300) begin
        #10
        $display("ADDR: %b, color: %b, wr_en: %b", fbuf_address, fbuf_color, fbuf_wr_en);
    end
    $finish;
end

endmodule;