module block (
    input  [3:0] inp_north,
    input  [3:0] inp_west,
    input        clk,
    input        rst,
    output reg [3:0] outp_south,
    output reg [3:0] outp_east,
    output reg [9:0] result
);

    wire [7:0] multi;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result     <= 8'd0;
            outp_east  <= 4'd0;
            outp_south <= 4'd0;
        end else begin
            result     <= result + multi;
            outp_east  <= inp_west;
            outp_south <= inp_north;
        end
    end

    assign multi = inp_north * inp_west;

endmodule











































































