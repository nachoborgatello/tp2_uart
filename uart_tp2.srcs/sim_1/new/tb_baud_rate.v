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
