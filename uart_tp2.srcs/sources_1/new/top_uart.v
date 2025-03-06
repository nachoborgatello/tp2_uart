`timescale 1ns / 1ps

module top_uart (
    input wire clk,
    input wire reset,
    input wire i_boton1, i_boton2, i_boton3, i_boton4,      // Botones
    input wire rx,
    output wire tx,
    output wire [7:0] r_data
);
    // Parámetros del baud_rate
    parameter FREQ_CLK = 50000000;
    parameter BAUD_RATE = 19200;
    parameter DBIT = 8;
    parameter SB_TICK=16;
    parameter FIFO_W=2;
    
    wire rd_uart, wr_uart;
    wire tx_full, rx_empty;
    
    wire o_tick, rx_done_tick, tx_done_tick;
    wire tx_empty, tx_fifo_not_empty;
    wire [7:0] tx_fifo_out, rx_data_out;
    
    wire [7:0] o_operandoA;                          // Registro para operandos A
    wire [7:0] o_operandoB;                          // Registro para operandos B
    wire [5:0] o_codigoOperacion;                    // Registro para el código de operación
    
    wire [7:0] w_data;

    // Instancia del módulo baud_rate
    baud_rate #(
        .FREQ_CLK(FREQ_CLK),
        .BAUD_RATE(BAUD_RATE)
    ) baud_rate_inst (
        .clk(clk),
        .reset(reset),
        .o_tick(o_tick)
    );
    
    uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
        (.clk(clk), .reset(reset), .rx(rx), .s_tick(o_tick),
        .rx_done_tick(rx_done_tick), .dout(rx_data_out));
        
    fifo #(.B(DBIT), .W(FIFO_W)) fifo_rx_unit
        (.clk(clk), .reset(reset), .rd(rd_uart),
        .wr(rx_done_tick), .w_data(rx_data_out),
        .empty(rx_empty), .full(), .r_data(r_data));
        
    fifo #(.B(DBIT), .W(FIFO_W)) fifo_tx_unit
        (.clk(clk), .reset(reset), .rd(tx_done_tick),
        .wr(wr_uart), .w_data(w_data),
        .empty(tx_empty), .full(tx_full), .r_data(tx_fifo_out));
        
    uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
        (.clk(clk), .reset(reset), .tx_start(tx_fifo_not_empty),
        .s_tick(o_tick), .din(tx_fifo_out), .tx_done_tick(tx_done_tick), .tx(tx));

    assign tx_fifo_not_empty = ~tx_empty;
    
    // Instancia el módulo de control de registros
    latch latch_unit (
        .i_btn1(i_boton1),
        .i_btn2(i_boton2),
        .i_btn3(i_boton3),
        .i_btn4(i_boton4),
        .i_sw(r_data),
        .i_clk(i_clk),
        .o_opA(o_operandoA),
        .o_opB(o_operandoB),
        .o_opcode(o_codigoOperacion)
    );
    
    // Instancia el módulo de la ALU
    alu alu_unit (
        .i_operandoA(o_operandoA),
        .i_operandoB(o_operandoB),
        .i_operacion(o_codigoOperacion),
        .o_resultado(w_data)
    );
    
endmodule