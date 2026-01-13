module tb_fbuf2rgb;

localparam FRAME_HEIGHT = 4;
localparam SCALING_FACTOR = 1;
localparam FBUF_ADDR_WIDTH = 8;
localparam CONTROL_DELAY = 1;

logic clk = 0;
logic rst_n = 0;
logic hsync;
logic vsync;
logic vde;
logic eof;
logic [FBUF_ADDR_WIDTH - 1 : 0] pixel_fbuf_address;
logic [12:0] pixel_x;
logic [12:0] pixel_y;

always #5 clk = ~clk; //create clk with 100 MHz

fbuf2rgb #(
    .FRAME_HEIGHT(FRAME_HEIGHT),
    .SCALING_FACTOR(SCALING_FACTOR),
    .FBUF_ADDR_WIDTH(FBUF_ADDR_WIDTH),
    .CONTROL_DELAY(CONTROL_DELAY)
) fbuf2rgb_instance(
    .clk(clk),
    .rst_n(rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .vde(vde),
    .eof(eof),
    .pixel_fbuf_address(pixel_fbuf_address),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y)
);

initial begin
    #10
    assert(vde == 0);
    assert(eof == 0);
    assert(hsync == 0);
    assert(vsync == 0);
    rst_n = 1;
    repeat(100) begin
        #10
        $display("X: %d, Y: %d, VDE: %d, HSYNC: %d, VSYNC: %d, EOF: %d", pixel_x, pixel_y, vde, hsync, vsync, eof);
        $display("ADDR: %d", pixel_fbuf_address);
    end
    $finish;
end

endmodule