module test_pattern_generator #(
        parameter FRAME_WIDTH = 1920,
        parameter FRAME_HEIGHT = 1080,
        parameter SCALING_FACTOR = 4
    ) (
        input wire clk,
        input wire rst_n,
        output reg [16:0] pixel_fbuf_address,
        output reg [11:0] pixel_fbuf_color,
        output reg pixel_fbuf_wr_en
    );

    reg [16:0] address_counter;
    reg [8:0] pixel_x_counter;
    reg [8:0] pixel_y_counter;

    always @(posedge clk) begin
        if (!rst_n) begin
            address_counter <= 0;
            pixel_x_counter <= 0;
            pixel_y_counter <= 0;
        end else begin
            if (pixel_y_counter == FRAME_HEIGHT / SCALING_FACTOR - 1) begin
                address_counter <= 0;
                pixel_x_counter <= 0;
                pixel_y_counter <= 0;
            end else begin
                address_counter <= address_counter + 1;
                if (pixel_x_counter == FRAME_WIDTH / SCALING_FACTOR - 1) begin
                    pixel_x_counter <= 0;
                    pixel_y_counter <= pixel_y_counter + 1;
                end else begin
                    pixel_x_counter <= pixel_x_counter + 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            pixel_fbuf_address <= 0;
            pixel_fbuf_color <= 0;
            pixel_fbuf_wr_en <= 0;
        end else begin
            pixel_fbuf_address <= address_counter;
            pixel_fbuf_wr_en <= 1;
            if (pixel_x_counter[4:0] == 5'b10000 | pixel_y_counter[4:0] == 5'b10000) begin
                pixel_fbuf_color <= 12'hf00;
            end else begin
                pixel_fbuf_color <= 12'h00f;
            end
        end
    end

endmodule