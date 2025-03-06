`timescale 1ns / 1ps

module baud_rate
    #(    
        parameter FREQ_CLK = 50000000,
        parameter BAUD_RATE = 19200
    )
    (
        input clk,
        input reset,
        output reg o_tick
    );
    
    localparam DIVISOR = FREQ_CLK / (BAUD_RATE * 16);
    
    reg [7:0] counter = 0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            o_tick <= 0;
        end else begin
            if (counter == DIVISOR) begin
                counter <= 0;
                o_tick <= ~o_tick;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule