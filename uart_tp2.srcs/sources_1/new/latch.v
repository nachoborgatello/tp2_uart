module latch(
    input i_btn1, i_btn2, i_btn3, i_btn4,   // Botones
    input [7:0] i_sw,                       // Interruptores
    input i_clk,                            // Señal de reloj
    output [7:0] o_opA,                     // Registro para operandos A
    output [7:0] o_opB,                     // Registro para operandos B
    output [7:0] o_opcode                   // Registro para el código de operación
);

    reg [7:0] reg_operandoA;                 // Registro para operandos A
    reg [7:0] reg_operandoB;                 // Registro para operandos B
    reg [7:0] reg_opcode;                    // Registro para el código de operación

    always @(posedge i_clk) 
        begin
            if (i_btn1) 
                begin
                    reg_operandoA <= i_sw;
                end
            if (i_btn2) 
                begin
                    reg_operandoB <= i_sw;
                end
            if (i_btn3) 
                begin
                    reg_opcode <= i_sw;
                end
            if (i_btn4) 
                begin
                    reg_operandoA <= 8'b0;
                    reg_operandoB <= 8'b0;
                    reg_opcode <= 8'b0;
                end
        end

    assign o_opA = reg_operandoA;
    assign o_opB = reg_operandoB;
    assign o_opcode = reg_opcode;

endmodule