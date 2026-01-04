module color_converter #(
    parameter SWITCH_RGB_TO_RBG = 1
) (
    input clk,
    input [11:0] in_color,
    output reg [23:0] out_color
);

    generate
        always @(posedge clk) begin
            if (SWITCH_RGB_TO_RBG == 0) begin
                out_color <= {in_color[11:8], 4'b0, in_color[7:4], 4'b0, in_color[3:0], 4'b0};
            end else begin
                out_color <= {in_color[11:8], 4'b0, in_color[3:0], 4'b0, in_color[7:4], 4'b0};
            end
        end
    endgenerate
endmodule