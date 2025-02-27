`timescale 1ns / 1ps

module baud_rate
    #(    
        parameter DVSR = 163,
        parameter DVSR_BIT = 8
    )
    (
        input clk,
        input reset,
        output wire o_tick
    );
    
    reg [DVSR_BIT-1:0] counter = 0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            o_tick <= 0;
        end else begin
            if (counter == DVSR) begin
                counter <= 0;
                o_tick <= ~o_tick;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule