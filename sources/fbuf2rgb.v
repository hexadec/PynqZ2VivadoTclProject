`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 10:18:13
// Design Name: 
// Module Name: fbuf2rgb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Use 2x-4x upscaling (for bigger resolutions) from framebuffer to limit BRAM use
module fbuf2rgb
#(
    parameter FRAME_HEIGHT = 480,
    parameter SCALING_FACTOR = 1,
    parameter FBUF_ADDR_WIDTH = 19,
    parameter CONTROL_DELAY = 1 // 1 extra delay is added in code to compensate for pixel address calculation delay
) (
    input wire clk,
    input wire rst_n,
    output wire hsync,
    output wire vsync,
    output wire vde,
    output wire eof,
    output wire [FBUF_ADDR_WIDTH - 1 : 0] pixel_fbuf_address,
    output wire [12:0] pixel_x,
    output wire [12:0] pixel_y
    );

    function integer frame_h;
        input integer value;
        if (value == 1080) begin
            frame_h = 1920;
        end else if (value == 720) begin
            frame_h = 1280;
        end else if (value == 600) begin
            frame_h = 800;
        end else if (value == 480) begin
            frame_h = 640;
        end else begin
            frame_h = 0;
        end
    endfunction

    function integer frame_h_front_porch;
        input integer value;
        if (value == 1080) begin
            frame_h_front_porch = 88;
        end else if (value == 720) begin
            frame_h_front_porch = 110;
        end else if (value == 600) begin
            frame_h_front_porch = 40;
        end else if (value == 480) begin
            frame_h_front_porch = 8;
        end else begin
            frame_h_front_porch = 0;
        end
    endfunction

    function integer frame_h_sync;
        input integer value;
        if (value == 1080) begin
            frame_h_sync = 44;
        end else if (value == 720) begin
            frame_h_sync = 40;
        end else if (value == 600) begin
            frame_h_sync = 128;
        end else if (value == 480) begin
            frame_h_sync = 96;
        end else begin
            frame_h_sync = 0;
        end
    endfunction

    function integer frame_h_back_porch;
        input integer value;
        if (value == 1080) begin
            frame_h_back_porch = 148;
        end else if (value == 720) begin
            frame_h_back_porch = 220;
        end else if (value == 600) begin
            frame_h_back_porch = 88;
        end else if (value == 480) begin
            frame_h_back_porch = 40;
        end else begin
            frame_h_back_porch = 0;
        end
    endfunction


    function integer frame_v;
        input integer value;
        if (value == 1080) begin
            frame_v = 1080;
        end else if (value == 720) begin
            frame_v = 720;
        end else if (value == 600) begin
            frame_v = 600;
        end else if (value == 480) begin
            frame_v = 480;
        end else begin
            frame_v = 0;
        end
    endfunction

    function integer frame_v_front_porch;
        input integer value;
        if (value == 1080) begin
            frame_v_front_porch = 4;
        end else if (value == 720) begin
            frame_v_front_porch = 5;
        end else if (value == 600) begin
            frame_v_front_porch = 1;
        end else if (value == 480) begin
            frame_v_front_porch = 2;
        end else begin
            frame_v_front_porch = 0;
        end
    endfunction

    function integer frame_v_sync;
        input integer value;
        if (value == 1080) begin
            frame_v_sync = 5;
        end else if (value == 720) begin
            frame_v_sync = 5;
        end else if (value == 600) begin
            frame_v_sync = 4;
        end else if (value == 480) begin
            frame_v_sync = 2;
        end else begin
            frame_v_sync = 0;
        end
    endfunction

    function integer frame_v_back_porch;
        input integer value;
        if (value == 1080) begin
            frame_v_back_porch = 36;
        end else if (value == 720) begin
            frame_v_back_porch = 20;
        end else if (value == 600) begin
            frame_v_back_porch = 23;
        end else if (value == 480) begin
            frame_v_back_porch = 25;
        end else begin
            frame_v_back_porch = 0;
        end
    endfunction


    function integer h_sync_active_low;
        input integer value;
        if (value == 1080) begin
            h_sync_active_low = 0;
        end else if (value == 720) begin
            h_sync_active_low = 0;
        end else if (value == 600) begin
            h_sync_active_low = 0;
        end else if (value == 480) begin
            h_sync_active_low = 0;
        end else begin
            h_sync_active_low = 0;
        end
    endfunction

    function integer v_sync_active_low;
        input integer value;
        if (value == 1080) begin
            v_sync_active_low = 0;
        end else if (value == 720) begin
            v_sync_active_low = 0;
        end else if (value == 600) begin
            v_sync_active_low = 0;
        end else if (value == 480) begin
            v_sync_active_low = 0;
        end else begin
            v_sync_active_low = 0;
        end
    endfunction

    localparam FRAME_H = frame_h(FRAME_HEIGHT);
    localparam FRAME_H_FRONT_PORCH = frame_h_front_porch(FRAME_HEIGHT);
    localparam FRAME_H_SYNC = frame_h_sync(FRAME_HEIGHT);
    localparam FRAME_H_BACK_PORCH = frame_h_back_porch(FRAME_HEIGHT);
    localparam FRAME_V = frame_v(FRAME_HEIGHT);
    localparam FRAME_V_FRONT_PORCH = frame_v_front_porch(FRAME_HEIGHT);
    localparam FRAME_V_SYNC = frame_v_sync(FRAME_HEIGHT);
    localparam FRAME_V_BACK_PORCH = frame_v_back_porch(FRAME_HEIGHT);
    localparam H_SYNC_ACTIVE_LOW = h_sync_active_low(FRAME_HEIGHT);
    localparam V_SYNC_ACTIVE_LOW = v_sync_active_low(FRAME_HEIGHT);
    
    localparam FRAME_H_TOTAL = FRAME_H + FRAME_H_FRONT_PORCH + FRAME_H_SYNC + FRAME_H_BACK_PORCH;
    localparam FRAME_V_TOTAL = FRAME_V + FRAME_V_FRONT_PORCH + FRAME_V_SYNC + FRAME_V_BACK_PORCH;
    
    localparam FRAME_H_SYNC_START = FRAME_H + FRAME_H_FRONT_PORCH;
    localparam FRAME_V_SYNC_START = FRAME_V + FRAME_V_FRONT_PORCH;
    
    localparam FRAME_H_SYNC_END = FRAME_H + FRAME_H_FRONT_PORCH + FRAME_H_SYNC;
    localparam FRAME_V_SYNC_END = FRAME_V + FRAME_V_FRONT_PORCH + FRAME_V_SYNC;
    
    reg [12:0] h_counter;
    reg [12:0] v_counter;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            h_counter <= 0;
            v_counter <= 0;
        end else if (h_counter == FRAME_H_TOTAL - 1) begin
            h_counter <= 0;
            if (v_counter == FRAME_V_TOTAL - 1) begin
                v_counter <= 0;
            end else begin
                v_counter <= v_counter + 1;
            end
        end else begin
            h_counter <= h_counter + 1;
        end
    end
    
    reg [CONTROL_DELAY : 0] vde_int;
    reg [CONTROL_DELAY : 0] eof_int;
    reg [CONTROL_DELAY : 0] hsync_int;
    reg [CONTROL_DELAY : 0] vsync_int;
    reg [12:0] pixel_x_int [CONTROL_DELAY : 0];
    reg [12:0] pixel_y_int [CONTROL_DELAY : 0];
    reg [FBUF_ADDR_WIDTH - 1 : 0] pixel_fbuf_address_int;
    
    
    integer i;
    integer j;
    always @(posedge clk) begin
        if (!rst_n) begin
            vde_int <= 0;
            eof_int <= 0;
            hsync_int <= 0;
            vsync_int <= 0;
            for (i = 0; i < CONTROL_DELAY + 1; i = i + 1) begin
                pixel_x_int[i] <= 0;
                pixel_y_int[i] <= 0;
            end
        end else begin
            vde_int <= {vde_int[CONTROL_DELAY - 1 : 0], h_counter < FRAME_H && v_counter < FRAME_V};
            eof_int <= {eof_int[CONTROL_DELAY - 1 : 0], v_counter >= FRAME_V};
            hsync_int <= {hsync_int[CONTROL_DELAY - 1 : 0], H_SYNC_ACTIVE_LOW ^ (h_counter >= FRAME_H_SYNC_START && h_counter < FRAME_H_SYNC_END)};
            vsync_int <= {vsync_int[CONTROL_DELAY - 1 : 0], V_SYNC_ACTIVE_LOW ^ (v_counter >= FRAME_V_SYNC_START && v_counter < FRAME_V_SYNC_END)};
            pixel_x_int[0] <= vde ? h_counter : 0;
            pixel_y_int[0] <= vde ? v_counter : 0;
            for (j = 1; j < CONTROL_DELAY + 1; j = j + 1) begin
                pixel_x_int[j] <= pixel_x_int[j - 1];
            end
            pixel_fbuf_address_int <= vde ? (v_counter / SCALING_FACTOR) * FRAME_V / SCALING_FACTOR + (h_counter / SCALING_FACTOR) : 0;
        end
    end
    
    assign vde = vde_int[CONTROL_DELAY];
    assign eof = eof_int[CONTROL_DELAY];
    assign hsync = hsync_int[CONTROL_DELAY];
    assign vsync = vsync_int[CONTROL_DELAY];
    
    assign pixel_x = pixel_x_int[CONTROL_DELAY];
    assign pixel_y = pixel_y_int[CONTROL_DELAY];

    assign pixel_fbuf_address = pixel_fbuf_address_int;
    
endmodule
