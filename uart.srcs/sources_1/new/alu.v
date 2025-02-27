`timescale 1ns / 1ps

module alu
    #(
        parameter tamanioEntrada=4,
        parameter tamanioSalida=4,
        parameter tamanioOperacion=6
    )
    (   
        input wire [tamanioEntrada-1:0] i_operandoA,
        input wire [tamanioEntrada-1:0] i_operandoB,
        input wire [tamanioOperacion-1:0] i_operacion,
        output wire [tamanioSalida-1:0] o_resultado
    );

    //Operaciones
    localparam ADD      =   6'b100000;
    localparam SUB      =   6'b100010;
    localparam AND      =   6'b100100; 
    localparam OR       =   6'b100101; 
    localparam XOR      =   6'b100110;
    localparam SRA      =   6'b000011;
    localparam SRL      =   6'b000010;
    localparam NOR      =   6'b100111;
    
    reg [tamanioSalida-1:0] temp;

    always @(*)
        begin: ALU
            case(i_operacion)      
                ADD : temp = i_operandoA + i_operandoB;
                SUB : temp = i_operandoA - i_operandoB;
                AND : temp = i_operandoA & i_operandoB;
                OR  : temp = i_operandoA | i_operandoB;
                XOR : temp = i_operandoA ^ i_operandoB;
                SRA : temp = i_operandoA << i_operandoB;
                SRL : temp = i_operandoA >> i_operandoB;
                NOR : temp = ~(i_operandoA | i_operandoB);
                default : temp = {tamanioSalida{1'b0}};   
            endcase
        end   //ALU
    assign o_resultado = temp;
endmodule