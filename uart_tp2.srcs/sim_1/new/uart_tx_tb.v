`timescale 1ns / 1ps

module uart_tx_tb;

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter M = 163; // divisor de baud rate (ajustar según reloj y baud rate)

reg clk, reset;
reg wr_uart;
reg [7:0] w_data;
wire s_tick;
wire tx_done_tick;
wire tx;

// Instancia del generador de ticks (baud rate)
mod_m_counter #(.N(8), .M(M)) baud_gen (
    .clk(clk),
    .reset(reset),
    .max_tick(s_tick),
    .q()
);

// Instancia del transmisor UART
uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) dut (
    .clk(clk),
    .reset(reset),
    .tx_start(wr_uart),
    .s_tick(s_tick),
    .din(w_data),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
);

// Generación de reloj
always #10 clk = ~clk;

// Secuencia de prueba
initial begin
    clk = 0;
    reset = 1;
    wr_uart = 0;
    w_data = 8'h00;

    #20 reset = 0;

    // Primer byte
    #20 w_data = 8'b01001011;
    wr_uart = 1;
    #20;
    wr_uart = 0;
    #555400;

    // Segundo byte
    #20 w_data = 8'b10110110;
    wr_uart = 1;
    #20;
    wr_uart = 0;
    #555400;

    $stop;
end

// Monitoreo
initial begin
    $monitor("t=%0t | w_data=%b | tx=%b | tx_done_tick=%b",
              $time, w_data, tx, tx_done_tick);
end

endmodule
