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

// Use 8x upscaling from framebuffer to limit BRAM use
module fbuf2rgb
#(
    parameter RESOLUTION = 1080
) (
    input wire clk,
    input wire rst_n,
    output wire hsync,
    output wire vsync,
    output wire vde,
    output wire eof,
    output wire [16:0] pixel_fbuf_address,
    output wire [12:0] pixel_x,
    output wire [12:0] pixel_y
    );

    generate
        if (RESOLUTION == 1080) begin : F_PROPS
            localparam FRAME_H = 1920;
            localparam FRAME_H_FRONT_PORCH = 88;
            localparam FRAME_H_SYNC = 44;
            localparam FRAME_H_BACK_PORCH = 148;
            localparam FRAME_V = 1080;
            localparam FRAME_V_FRONT_PORCH = 4;
            localparam FRAME_V_SYNC = 5;
            localparam FRAME_V_BACK_PORCH = 36;
            localparam H_SYNC_ACTIVE_LOW = 0;
            localparam V_SYNC_ACTIVE_LOW = 0;
        end else if (RESOLUTION == 720) begin : F_PROPS
            localparam FRAME_H = 1280;
            localparam FRAME_H_FRONT_PORCH = 110;
            localparam FRAME_H_SYNC = 40;
            localparam FRAME_H_BACK_PORCH = 220;
            localparam FRAME_V = 720;
            localparam FRAME_V_FRONT_PORCH = 5;
            localparam FRAME_V_SYNC = 5;
            localparam FRAME_V_BACK_PORCH = 20;
            localparam H_SYNC_ACTIVE_LOW = 0;
            localparam V_SYNC_ACTIVE_LOW = 0;
        end else if (RESOLUTION == 600) begin: F_PROPS
            localparam FRAME_H = 800;
            localparam FRAME_H_FRONT_PORCH = 40;
            localparam FRAME_H_SYNC = 128;
            localparam FRAME_H_BACK_PORCH = 88;
            localparam FRAME_V = 600;
            localparam FRAME_V_FRONT_PORCH = 1;
            localparam FRAME_V_SYNC = 4;
            localparam FRAME_V_BACK_PORCH = 23;
            localparam H_SYNC_ACTIVE_LOW = 0;
            localparam V_SYNC_ACTIVE_LOW = 0;
        end else begin
            invalid_fbuf2rgb_resolution();
        end
    endgenerate
    
    localparam FRAME_H_TOTAL = F_PROPS.FRAME_H + F_PROPS.FRAME_H_FRONT_PORCH + F_PROPS.FRAME_H_SYNC + F_PROPS.FRAME_H_BACK_PORCH;
    localparam FRAME_V_TOTAL = F_PROPS.FRAME_V + F_PROPS.FRAME_V_FRONT_PORCH + F_PROPS.FRAME_V_SYNC + F_PROPS.FRAME_V_BACK_PORCH;
    
    localparam FRAME_H_SYNC_START = F_PROPS.FRAME_H + F_PROPS.FRAME_H_FRONT_PORCH;
    localparam FRAME_V_SYNC_START = F_PROPS.FRAME_V + F_PROPS.FRAME_V_FRONT_PORCH;
    
    localparam FRAME_H_SYNC_END = F_PROPS.FRAME_H + F_PROPS.FRAME_H_FRONT_PORCH + F_PROPS.FRAME_H_SYNC;
    localparam FRAME_V_SYNC_END = F_PROPS.FRAME_V + F_PROPS.FRAME_V_FRONT_PORCH + F_PROPS.FRAME_V_SYNC;
    
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
    
    assign vde = h_counter < F_PROPS.FRAME_H && v_counter < F_PROPS.FRAME_V;
    assign eof = v_counter >= F_PROPS.FRAME_V;
    assign hsync = F_PROPS.H_SYNC_ACTIVE_LOW ^ (h_counter >= FRAME_H_SYNC_START && h_counter < FRAME_H_SYNC_END);
    assign vsync = F_PROPS.V_SYNC_ACTIVE_LOW ^ (v_counter >= FRAME_V_SYNC_START && v_counter < FRAME_V_SYNC_END);
    
    assign pixel_x = vde ? h_counter : 0;
    assign pixel_y = vde ? v_counter : 0;

    assign pixel_fbuf_address = vde ? (h_counter / 8) * F_PROPS.FRAME_H / 8 + (v_counter / 8) : 0;
    
endmodule