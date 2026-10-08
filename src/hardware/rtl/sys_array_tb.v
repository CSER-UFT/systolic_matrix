`include "systolic_array.v"

module sys_array_tb;

    reg rst, clk;
    reg [3:0] inp_west0, inp_west3, inp_west6;
    reg [3:0] inp_north0, inp_north1, inp_north2;
    wire done;

    systolic_array uut (
        inp_west0, inp_west3, inp_west6,
        inp_north0, inp_north1, inp_north2,
        clk, rst, done
    );

    initial begin
        rst = 1'b1;
        clk = 1'b0;
        inp_west0 = 4'd0; inp_west3 = 4'd0; inp_west6 = 4'd0;
        inp_north0 = 4'd0; inp_north1 = 4'd0; inp_north2 = 4'd0;
        #3 rst = 1'b0;
    end

    // Fluxos escalonados para a matriz 3x3; todos os operandos sao de 4 bits.
    initial begin
        #3  begin inp_west0 = 4'd3; inp_west3 = 4'd0; inp_west6 = 4'd0;
                  inp_north0 = 4'd4; inp_north1 = 4'd0; inp_north2 = 4'd0; end
        #10 begin inp_west0 = 4'd2; inp_west3 = 4'd6; inp_west6 = 4'd0;
                  inp_north0 = 4'd3; inp_north1 = 4'd5; inp_north2 = 4'd0; end
        #10 begin inp_west0 = 4'd1; inp_west3 = 4'd5; inp_west6 = 4'd9;
                  inp_north0 = 4'd2; inp_north1 = 4'd4; inp_north2 = 4'd6; end
        #10 begin inp_west0 = 4'd0; inp_west3 = 4'd4; inp_west6 = 4'd8;
                  inp_north0 = 4'd0; inp_north1 = 4'd3; inp_north2 = 4'd5; end
        #10 begin inp_west0 = 4'd0; inp_west3 = 4'd0; inp_west6 = 4'd7;
                  inp_north0 = 4'd0; inp_north1 = 4'd0; inp_north2 = 4'd4; end
        #10 begin inp_west0 = 4'd0; inp_west3 = 4'd0; inp_west6 = 4'd0;
                  inp_north0 = 4'd0; inp_north1 = 4'd0; inp_north2 = 4'd0; end
    end

    initial begin
        repeat (16) #5 clk = ~clk;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sys_array_tb);
    end

endmodule
