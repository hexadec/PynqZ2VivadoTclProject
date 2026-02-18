module tb_color_converter;

localparam FBUF_DATA_WIDTH = 8;

logic clk = 0;
logic [FBUF_DATA_WIDTH - 1 : 0] converter_in_color = 0;
logic [23:0] converter_out_color;

logic [23:0] converter_out_color_switch;

always #5 clk = ~clk; //create clk with 100 MHz

color_converter #(
    .SWITCH_RGB_TO_RBG(0),
    .FBUF_DATA_WIDTH(FBUF_DATA_WIDTH)
) color_converter_module_noswitch(
    .clk(clk),
    .in_color(converter_in_color),
    .out_color(converter_out_color)
);

color_converter #(
    .SWITCH_RGB_TO_RBG(1),
    .FBUF_DATA_WIDTH(FBUF_DATA_WIDTH)
) color_converter_module_switch(
    .clk(clk),
    .in_color(converter_in_color),
    .out_color(converter_out_color_switch)
);

initial begin
    #10
    assert(converter_out_color == 24'b0);
    assert(converter_out_color_switch == 24'b0);
    converter_in_color = 8'b11100000;
    #10
    assert(converter_out_color[23:16] == 8'b11100000);
    assert(converter_out_color[15:8] == 8'b0);
    assert(converter_out_color[7:0] == 8'b0);

    assert(converter_out_color_switch[23:16] == 8'b11100000);
    assert(converter_out_color_switch[15:8] == 8'b0);
    assert(converter_out_color_switch[7:0] == 8'b0);

    converter_in_color = 8'b00011100;
    #10
    assert(converter_out_color[23:16] == 8'b0);
    assert(converter_out_color[15:8] == 8'b11100000);
    assert(converter_out_color[7:0] == 8'b0);

    assert(converter_out_color_switch[23:16] == 8'b0);
    assert(converter_out_color_switch[15:8] == 8'b0);
    assert(converter_out_color_switch[7:0] == 8'b11100000);

    converter_in_color = 8'b00000011;
    #10
    assert(converter_out_color[23:16] == 8'b0);
    assert(converter_out_color[15:8] == 8'b0);
    assert(converter_out_color[7:0] == 8'b11000000);

    assert(converter_out_color_switch[23:16] == 8'b0);
    assert(converter_out_color_switch[15:8] == 8'b11000000);
    assert(converter_out_color_switch[7:0] == 8'b0);

    $finish;
end

endmodule
