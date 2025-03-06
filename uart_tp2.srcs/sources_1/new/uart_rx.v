`timescale 1ns / 1ps

module uart_rx
    #(
        parameter DBIT = 8,     // # data bits
        parameter SB_TICK = 16  // # ticks for stop bits
    )
    (
        input wire clk, reset,
        input wire rx, s_tick,
        output reg rx_done_tick, 
        output wire [7:0] dout
    );
    
    //Signal declaration 
    reg [1:0] state_reg , state_next; 
    reg [3:0] s_reg , s_next; 
    reg [2:0] n_reg , n_next; 
    reg [7:0] b_reg , b_next; 
    
    //FSMD_state_and_data_registers
    always @(posedge clk, posedge reset)
            if(reset)
                begin
                    state_reg <= 2'b00; 
                    s_reg <= 0; 
                    n_reg <= 0; 
                    b_reg <= 0;
                end
            else
                begin
                    state_reg <= state_next; 
                    s_reg <= s_next; 
                    n_reg <= n_next; 
                    b_reg <= b_next;                    
                end
            
    // FSMD next-state logic
    always @*
    begin
        state_next = state_reg;
        rx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        case(state_reg)
            // Idle
            2'b00:
                if(~rx)
                    begin
                        state_next = 2'b01;
                        s_next = 0;
                    end
            // Start
            2'b01:
                if(s_tick)
                    if (s_reg==7)
                        begin
                            state_next = 2'b10;
                            s_next = 0;
                            n_next = 0;
                        end
                    else
                        s_next = s_reg + 1;
            // Data
            2'b10:
                if(s_tick)
                    if (s_reg==15)
                        begin
                            s_next = 0;
                            b_next = {rx,b_reg[7:1]};
                            if (n_reg==(DBIT-1))
                                state_next = 2'b11;
                            else
                                n_next = n_reg + 1; 
                        end
                    else
                        s_next = s_reg + 1;
            // Stop
            2'b11:
                if(s_tick)
                    if (s_reg==(SB_TICK-1))
                        begin
                            state_next = 2'b00;
                            rx_done_tick = 1'b1;
                        end
                    else
                        s_next = s_reg + 1;
        endcase
    end
    
    assign dout = b_reg;
endmodule