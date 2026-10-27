`include "block.v"

module systolic_array #(
    parameter integer SIZE         = 16,
    parameter integer DATA_WIDTH   = 8,
    parameter integer RESULT_WIDTH = 20
) (
    input  [SIZE*DATA_WIDTH-1:0] inp_west,//125
    input  [SIZE*DATA_WIDTH-1:0] inp_north,//125
    input                        clk,
    input                        rst,
    output reg                   done
);

    localparam integer CHANNELS     = SIZE * (SIZE + 1);//272
    localparam integer TOTAL_CYCLES = (3 * SIZE) - 2;//46

    wire [CHANNELS*DATA_WIDTH-1:0] horizontal;
    wire [CHANNELS*DATA_WIDTH-1:0] vertical;

    // Barramento interno com os SIZE*SIZE resultados. O testbench pode
    // acessa-lo hierarquicamente como uut.results.
    wire [SIZE*SIZE*RESULT_WIDTH-1:0] results;

    reg [7:0] count;
    genvar row, col;

    generate
        for (row = 0; row < SIZE; row = row + 1) begin : GEN_WEST_INPUTS
            assign horizontal[(row*(SIZE+1))*DATA_WIDTH +: DATA_WIDTH] =
                inp_west[row*DATA_WIDTH +: DATA_WIDTH];
        end

        for (col = 0; col < SIZE; col = col + 1) begin : GEN_NORTH_INPUTS
            assign vertical[col*DATA_WIDTH +: DATA_WIDTH] =
                inp_north[col*DATA_WIDTH +: DATA_WIDTH];
        end

        for (row = 0; row < SIZE; row = row + 1) begin : GEN_ROWS
            for (col = 0; col < SIZE; col = col + 1) begin : GEN_COLS
                block pe (
                    .inp_north (
                        vertical[((row*SIZE)+col)*DATA_WIDTH +: DATA_WIDTH]
                    ),
                    .inp_west (
                        horizontal[((row*(SIZE+1))+col)*DATA_WIDTH +: DATA_WIDTH]
                    ),
                    .clk        (clk),
                    .rst        (rst),
                    .outp_south (
                        vertical[(((row+1)*SIZE)+col)*DATA_WIDTH +: DATA_WIDTH]
                    ),
                    .outp_east  (
                        horizontal[((row*(SIZE+1))+col+1)*DATA_WIDTH +: DATA_WIDTH]
                    ),
                    .result     (
                        results[((row*SIZE)+col)*RESULT_WIDTH +: RESULT_WIDTH]
                    )
                );
            end
        end
    endgenerate

    // A ultima multiplicacao chega ao PE (15,15) no ciclo 45.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done  <= 1'b0;
            count <= 8'd0;
        end else if (count == TOTAL_CYCLES - 1) begin
            done  <= 1'b1;
            count <= 8'd0;
        end else begin
            done  <= 1'b0;
            count <= count + 1'b1;
        end
    end

endmodule
