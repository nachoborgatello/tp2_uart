`timescale 1ns / 1ps

module top
   #( // Default setting:
      // 19200 baud, 8 data bits, 1 stop bit, 2^2 FIFO
      parameter DBIT = 8,
                SB_TICK = 16,
                DVSR = 325,   // baud rate divisor
                              // DVSR = 100MHz/(16*baudios)
                DVSR_BIT = 10,// # bits of DVSR
                FIFO_W = 4    // # addr bits of FIFO
                              // # words in FIFO=2^FIFO_W
   )
   (
    input wire clk, reset,
    input wire rd_uart, rx,
    input wire wr_uart,      
    output wire [7:0] r_data,
    output wire [7:0] alu_output,
    output wire tx_full, tx,
    output wire rx_empty
   );

   // Señales internas
   wire tick, rx_done_tick;
   wire [7:0] rx_data_out;
   wire rd_uart_tick, wr_tick;
   wire [7:0] w_data;
   
   wire tx_done_tick;
   wire tx_empty, tx_fifo_not_empty;
   wire [7:0] tx_fifo_out;

   reg [7:0] operandoA = 0;     
   reg [7:0] operandoB = 0;      
   reg [7:0] codigoOperacion = 0; 
   reg [7:0] prev_opcode = 0; // Estado previo del opcode
   
   debounce btn1_db_unit
    (.clk(clk), .reset(reset), .sw(rd_uart),
     .db_level(), .db_tick(rd_uart_tick));
     
   debounce btn2_db_unit
    (.clk(clk), .reset(reset), .sw(wr_uart),
     .db_level(), .db_tick(wr_tick));     
   
   mod_m_counter #(.M(DVSR), .N(DVSR_BIT)) baud_gen_unit
      (.clk(clk), .reset(reset), .q(), .max_tick(tick));

   uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
      (.clk(clk), .reset(reset), .rx(rx), .s_tick(tick),
       .rx_done_tick(rx_done_tick), .dout(rx_data_out));

   fifo #(.B(DBIT), .W(FIFO_W)) fifo_rx_unit
      (.clk(clk), .reset(reset), .rd(rd_uart_tick),
       .wr(rx_done_tick), .w_data(rx_data_out),
       .empty(rx_empty), .full(), .r_data(r_data));
    
    // OpCodes
    localparam ALU_DATA_A_OP    = 8'b11110101; //253
    localparam ALU_DATA_B_OP    = 8'b11111110; //254
    localparam ALU_OPERATOR_OP  = 8'b11111111; //255
        
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            operandoA        <= 0;
            operandoB        <= 0;
            codigoOperacion  <= 0;
            prev_opcode      <= 0;
        end 
        else if (!rx_empty && rd_uart_tick) begin
            if (r_data == ALU_DATA_A_OP || r_data == ALU_DATA_B_OP || r_data == ALU_OPERATOR_OP) begin
                prev_opcode <= r_data;  // Guarda solo si es un opcode
            end 
            else begin
                case (prev_opcode)
                    ALU_DATA_A_OP:    operandoA       <= r_data;
                    ALU_DATA_B_OP:    operandoB       <= r_data;
                    ALU_OPERATOR_OP:  codigoOperacion <= r_data;
                endcase
            end
        end
    end

   // Instancia del módulo de la ALU
   alu alu (
       .operandoA(operandoA),
       .operandoB(operandoB),
       .operacion(codigoOperacion),
       .resultado(alu_output)
   );
   
   fifo #(.B(DBIT), .W(FIFO_W)) fifo_tx_unit
      (.clk(clk), .reset(reset), .rd(tx_done_tick),
       .wr(wr_tick), .w_data(w_data), .empty(tx_empty),
       .full(tx_full), .r_data(tx_fifo_out));
       
   uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
      (.clk(clk), .reset(reset), .tx_start(tx_fifo_not_empty),
       .s_tick(tick), .din(tx_fifo_out),
       .tx_done_tick(tx_done_tick), .tx(tx));

   assign w_data = alu_output;
   assign tx_fifo_not_empty = ~tx_empty;      

endmodule