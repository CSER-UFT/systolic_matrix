`timescale 1ns/1ps

module tb_sevenseg_test;

    reg  mclk;
    wire [3:0] D0_a;
    wire [7:0] D0_seg;

    sevenseg_test dut (
        .mclk(mclk),
        .D0_a(D0_a),
        .D0_seg(D0_seg)
    );

    // Clock 100 MHz
    initial begin
        mclk = 0;
        forever #5 mclk = ~mclk;
    end

    // Tempo de simulação
    initial begin
        #5_000_000; // 5 ms
        $finish;
    end

endmodule
