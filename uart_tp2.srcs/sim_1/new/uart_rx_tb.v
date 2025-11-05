`timescale 1ns / 1ps

module uart_rx_tb;

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter M = 163; // divisor del baud rate (ajustar si es necesario)

reg clk, reset;
reg rx;
reg rd_uart;
wire s_tick;
wire rx_done_tick;
wire [7:0] dout;

integer i;
reg [7:0] data;

// Instancia del generador de ticks (divisor de baud rate)
mod_m_counter #(.N(8), .M(M)) baud_gen (
    .clk(clk),
    .reset(reset),
    .max_tick(s_tick),
    .q()
);

// Instancia del receptor UART
uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) dut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(s_tick),
    .rx_done_tick(rx_done_tick),
    .dout(dout)
);

// Generación de reloj
always #10 clk = ~clk;

// Secuencia de prueba
initial begin
    clk = 0;
    reset = 1;
    rd_uart = 0;
    rx = 1;
    #20 reset = 0;

    // Primer byte
    #500;
    data = 8'b10010101;
    rx = 0; // start bit
    #51041;
    for (i = 0; i < 8; i = i + 1) begin
        rx = data[i];
        #51041;
    end
    rx = 1; // stop bit
    #51041;

    // Segundo byte
    #50000;
    data = 8'b10111101;
    rx = 0; // start bit
    #51041;
    for (i = 0; i < 8; i = i + 1) begin
        rx = data[i];
        #51041;
    end
    rx = 1; // stop bit
    #51041;

    // Lectura UART simulada
    #500;
    rd_uart = 1;
    #500;
    rd_uart = 0;

    #500;
    $finish;
end

// Monitoreo
initial begin
    $monitor("t=%0t | rx=%b | dout=%b | rx_done_tick=%b", 
              $time, rx, dout, rx_done_tick);
end

endmodule
