`include "block.v"

module systolic_array (
    input [3:0] inp_west0, inp_west3, inp_west6,
    input [3:0] inp_north0, inp_north1, inp_north2,
    input clk, rst,
    output reg done
);

    reg [2:0] count;

    wire [3:0] outp_south0, outp_south1, outp_south2;
    wire [3:0] outp_south3, outp_south4, outp_south5;
    wire [3:0] outp_south6, outp_south7, outp_south8;
    wire [3:0] outp_east0, outp_east1, outp_east2;
    wire [3:0] outp_east3, outp_east4, outp_east5;
    wire [3:0] outp_east6, outp_east7, outp_east8;
    wire [9:0] result0, result1, result2;
    wire [9:0] result3, result4, result5;
    wire [9:0] result6, result7, result8;

    // Primeira linha.
    block P0 (inp_north0, inp_west0,   clk, rst, outp_south0, outp_east0, result0);
    block P1 (inp_north1, outp_east0,  clk, rst, outp_south1, outp_east1, result1);
    block P2 (inp_north2, outp_east1,  clk, rst, outp_south2, outp_east2, result2);

    // Segunda linha.
    block P3 (outp_south0, inp_west3,  clk, rst, outp_south3, outp_east3, result3);
    block P4 (outp_south1, outp_east3, clk, rst, outp_south4, outp_east4, result4);
    block P5 (outp_south2, outp_east4, clk, rst, outp_south5, outp_east5, result5);

    // Terceira linha.
    block P6 (outp_south3, inp_west6,  clk, rst, outp_south6, outp_east6, result6);
    block P7 (outp_south4, outp_east6, clk, rst, outp_south7, outp_east7, result7);
    block P8 (outp_south5, outp_east7, clk, rst, outp_south8, outp_east8, result8);

    // Para uma matriz 3x3, o pulso de conclusao ocorre a cada seis ciclos.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done  <= 1'b0;
            count <= 3'd0;
        end else if (count == 3'd5) begin
            done  <= 1'b1;
            count <= 3'd0;
        end else begin
            done  <= 1'b0;
            count <= count + 3'd1;
        end
    end

endmodule
