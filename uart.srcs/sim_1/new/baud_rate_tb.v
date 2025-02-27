`timescale 1ns / 1ps

module baud_rate_tb;
    reg clk;
    reg reset;
    wire o_tick;

    baud_rate #(
        .FREQ_CLK(50000000),  // Frecuencia del reloj (50 MHz)
        .BAUD_RATE(19200)     // Baud rate
    ) dut (
        .clk(clk),
        .reset(reset),
        .o_tick(o_tick)
    );

    // Generar el reloj de 50 MHz
    always #10 clk = ~clk; // Periodo de 20 ns (50 MHz)

    initial begin
        // Inicialización
        clk = 0;
        reset = 1;

        // Mantener reset activo por unos ciclos de reloj
        #100;
        reset = 0;

        // Simulación por cierto tiempo
        #1000000;
        
        // Finalizar simulación
        $finish;
    end

    // Monitor para ver los cambios de las señales
    initial begin
        $monitor("Time: %d, Reset: %b, Baud_out: %b", $time, reset, o_tick);
    end

endmodule