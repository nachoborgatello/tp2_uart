`timescale 1ns / 1ps

module alu_tb;

    reg [3:0] i_operandoA;
    reg [3:0] i_operandoB;
    reg [5:0] i_operacion;
    wire [3:0] o_resultado;

    alu #(
        .tamanioEntrada(4),
        .tamanioSalida(4),
        .tamanioOperacion(6)
    ) dut (
        .i_operandoA(i_operandoA),
        .i_operandoB(i_operandoB),
        .i_operacion(i_operacion),
        .o_resultado(o_resultado)
    );

    initial begin
        // Inicializar señales
        i_operandoA = 0;
        i_operandoB = 0;
        i_operacion = 0;

        // Monitor para observar los cambios
        $monitor("Time: %0t | OperandoA: %b | OperandoB: %b | Operacion: %b | Resultado: %b", 
                  $time, i_operandoA, i_operandoB, i_operacion, o_resultado);

        #10 
        i_operandoA = 4'b0111; // 7
        i_operandoB = 4'b0001; // 1
        
        i_operacion = 6'b100000; // ADD
        
        #10;    
        i_operacion = 6'b100010; // SUB
        
        #10;
        i_operacion = 6'b100100; // AND
        
        #10;
        i_operacion = 6'b100101; // OR
        
        #10;
        i_operacion = 6'b100110; // XOR
        
        #10;
        i_operacion = 6'b000010; // SRL
        
        #10;
        i_operacion = 6'b000011; // SRA
        
        #10;
        i_operacion = 6'b100111; // NOR

        // Finalizar simulación
        #10 $finish;
    end
endmodule