module uart
    #(  // Default setting:
        // 19200 baud, 8 data bits, 1 stop bit, 2*2 FIFO
        parameter   DBIT = 8,
                    SB_TICK = 16,
                    DVSR = 163,
                    DVSR_BIT = 8,
                    FIFO_W = 2

    )
    (
        input wire clk, reset,
        input wire rd_uart, wr_uart, rx,
        input wire [7:0] w_data,
        output wire tx_full, rx_empty, tx,
        output wire [7:0] r_data
    );
    
    // signal declaration
    wire tick, rx_done_tick, tx_done_tick;
    wire tx_empty, tx_fifo_not_empty;
    wire [7:0] tx_fifo_out, rx_data_out;
    
    // body
    
    baud_rate #(.DVSR(DVSR), .DVSR_BIT(DVSR_BIT)) baud_gen_unit 
        (.clk(c1k) , .reset (reset), .o_tick(tick)) ;
    
    uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
        (   .clk(clk), .reset (reset), .rx(rx), .s_tick(tick), 
            .rx_done_tick(rx_done_tick), .dout(rx_data_out)); 
    
    flag_buf #(.B(DBIT), .W(FIFO_W)) fifo_rx_unit
        (   .clk(clk), .reset(reset), .rd(rd_uart),
            .wr(rx_done_tick), .w_data(rx_data_out),
            .empty(rx_empty), .full(), .r_data(r_data));   

    flag_buf #(.B(DBIT), .W(FIFO_W)) fifo_tx_unit
        (   .clk(clk), .reset(reset), .rd(tx_done_tick),
            .wr(wr_uart), .w_data(w_data),
            .empty(tx_empty), .full(tx_full), .r_data(tx_fifo_out));
                    
    uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
        (   .clk(clk), .reset (reset), .tx_start(tx_fifo_not_empty), 
            .s_tick(tick), .din(tx_fifo_out), 
            .tx_done_tick(tx_done_tick), .tx(tx));
    
    assign tx_fifo_not_empty = ~tx_empty; 
endmodule















