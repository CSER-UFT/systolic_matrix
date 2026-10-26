//Elementos de uma única PE:
module block (
    input  [7:0] inp_north,
    input  [7:0] inp_west,
    input        clk,
    input        rst,
    output reg [7:0] outp_south,
    output reg [7:0] outp_east,
    output reg [19:0] result
);

    wire [15:0] multi;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result     <= '0;
            outp_east  <= '0;
            outp_south <= '0;
        end else begin
            result     <= result + multi;
            outp_east  <= inp_west;
            outp_south <= inp_north;
        end
    end

    assign multi = inp_north * inp_west;

endmodule







































































