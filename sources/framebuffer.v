module framebuffer #(
    parameter ADDR_WIDTH = 17,
    parameter DATA_WIDTH = 12
    ) (
    input clk_wr, clk_rd, en_wr, en_rd, wrea,
    input [ADDR_WIDTH - 1:0] addr_rd, addr_wr,
    input [DATA_WIDTH - 1:0] din, 
    output reg [DATA_WIDTH - 1:0] dout
    );

    reg [DATA_WIDTH - 1:0] ram [(2 ** ADDR_WIDTH) - 1:0];
    
    always @(posedge clk_wr) begin
        if (en_wr) begin
            if (wrea)
                ram[addr_wr] <= din;
        end
    end

    always @(posedge clk_rd) begin
        if (en_rd)  begin
            dout <= ram[addr_rd];
        end
    end

endmodule