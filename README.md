# 🛰️ UART – Trabajo Práctico 2

**Arquitectura de Computadoras – 2025**

---

## 📘 Descripción General

Este proyecto implementa un **UART (Universal Asynchronous Receiver and Transmitter)** en **Verilog**, utilizando **Máquinas de Estado Finitas (FSM)**.
Incluye los siguientes módulos principales:

1. **Generador de Baud Rate (`mod_m_counter`)**
   Controla la frecuencia de transmisión/recepción de datos.

2. **Receptor UART (`uart_rx`)**
   Detecta el bit de inicio, recibe los bits de datos y el bit de parada, ensamblando el byte recibido.

3. **Transmisor UART (`uart_tx`)**
   Envía los bits en serie respetando la secuencia y tiempos del protocolo UART.

4. **FIFO**
   Implementa un buffer de datos para el almacenamiento temporal de los bytes recibidos o a transmitir.

5. **Antirrebotes (debounce)**
   Estabiliza las señales provenientes de pulsadores físicos.

6. **ALU**
   Procesa los datos recibidos mediante operaciones aritméticas y lógicas.

7. **Top Module**
   Integra todos los componentes anteriores en un sistema funcional.

---

## ⚙️ Módulo Baud Rate

### Descripción

El módulo `mod_m_counter` genera una señal de tick (`max_tick`) a partir de la frecuencia del reloj del sistema, dividiendo la frecuencia para ajustar el **baud rate** deseado.

### Ejemplo:

Con un reloj de **100 MHz** y una velocidad de **19200 baudios**, se obtiene:

```
100 MHz / (19200 * 16) = 325 ticks
```

### Código del testbench `baud_rate_tb.v`

```verilog
module baud_rate_tb;

parameter N = 8;
parameter M = 163;

reg clk;
reg reset;
wire max_tick;
wire [N-1:0] q;

mod_m_counter #(.N(N), .M(M)) dut (
    .clk(clk),
    .reset(reset),
    .max_tick(max_tick),
    .q(q)
);

always #10 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    #20 reset = 0;
    #200;
    $stop;
end

initial begin
    $monitor("Time=%0t | q=%d | max_tick=%b", $time, q, max_tick);
end

endmodule
```

---

## 📥 Módulo UART Rx

### Descripción

Recibe bytes en formato UART, sincronizando los bits de inicio, datos y parada mediante una FSM.
Se genera un pulso `rx_done_tick` al completar la recepción de un byte.

### Testbench `uart_rx_tb.v`

```verilog
`timescale 1ns / 1ps

module uart_rx_tb;

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter M = 163;

reg clk, reset;
reg rx;
reg rd_uart;
wire s_tick;
wire rx_done_tick;
wire [7:0] dout;

integer i;
reg [7:0] data;

mod_m_counter #(.N(8), .M(M)) baud_gen (
    .clk(clk),
    .reset(reset),
    .max_tick(s_tick),
    .q()
);

uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) dut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(s_tick),
    .rx_done_tick(rx_done_tick),
    .dout(dout)
);

always #10 clk = ~clk;

initial begin
    clk = 0; reset = 1; rd_uart = 0; rx = 1;
    #20 reset = 0;

    #500; data = 8'b10010101; rx = 0;
    #51041; for (i = 0; i < 8; i = i + 1) begin rx = data[i]; #51041; end
    rx = 1; #51041;

    #50000; data = 8'b10111101; rx = 0;
    #51041; for (i = 0; i < 8; i = i + 1) begin rx = data[i]; #51041; end
    rx = 1; #51041;

    #500; rd_uart = 1; #500; rd_uart = 0;
    #500; $finish;
end

initial begin
    $monitor("t=%0t | rx=%b | dout=%b | rx_done_tick=%b",
              $time, rx, dout, rx_done_tick);
end

endmodule
```

---

## 📤 Módulo UART Tx

### Descripción

El transmisor UART envía los bits de inicio, datos y parada con la temporización correcta.
Genera un pulso `tx_done_tick` al finalizar la transmisión de un byte.

### Testbench `uart_tx_tb.v`

```verilog
`timescale 1ns / 1ps

module uart_tx_tb;

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter M = 163;

reg clk, reset;
reg wr_uart;
reg [7:0] w_data;
wire s_tick;
wire tx_done_tick;
wire tx;

mod_m_counter #(.N(8), .M(M)) baud_gen (
    .clk(clk),
    .reset(reset),
    .max_tick(s_tick),
    .q()
);

uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) dut (
    .clk(clk),
    .reset(reset),
    .tx_start(wr_uart),
    .s_tick(s_tick),
    .din(w_data),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
);

always #10 clk = ~clk;

initial begin
    clk = 0; reset = 1; wr_uart = 0; w_data = 8'h00;
    #20 reset = 0;

    #20 w_data = 8'b01001011; wr_uart = 1; #20; wr_uart = 0; #555400;
    #20 w_data = 8'b10110110; wr_uart = 1; #20; wr_uart = 0; #555400;

    $stop;
end

initial begin
    $monitor("t=%0t | w_data=%b | tx=%b | tx_done_tick=%b",
              $time, w_data, tx, tx_done_tick);
end

endmodule
```

---

## 💡 Simulación

Los testbenches permiten verificar el comportamiento de cada módulo por separado.
En **Vivado/ModelSim**, se pueden observar:

* La secuencia de bits transmitidos y recibidos.
* Los pulsos `rx_done_tick` y `tx_done_tick` que indican la finalización de transmisión o recepción.
* La señal `max_tick` del generador de baud rate.

---

## 🧩 Integración en el Módulo Top

El módulo `top.v` combina todos los componentes anteriores junto con la **ALU**, **FIFO** y **debounce**, permitiendo:

* Recepción de datos desde la PC.
* Procesamiento mediante la ALU.
* Visualización en LEDs y retransmisión del resultado.

---

## 📚 Referencias

* Chu, P. P. *FPGA Prototyping by VHDL Examples: Xilinx Spartan-3 Version*. Wiley, 2008.
* Documentación oficial de Xilinx Vivado Design Suite.

---