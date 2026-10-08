module sevenseg_test (
    input  wire        mclk,      // 100 MHz
    output reg  [3:0]  D0_a,       // anodos (ativos em 0)
    output reg  [7:0]  D0_seg      // {dp,g,f,e,d,c,b,a} (ativos em 0)
);

    // =====================================================
    // Blink: 2 segundos (100 MHz)
    // =====================================================
    localparam integer BLINK_MAX = 200_000_000;
    reg [27:0] blink_cnt = 0;
    reg        blink_en  = 1'b1;

    always @(posedge mclk) begin
        if (blink_cnt == BLINK_MAX-1) begin
            blink_cnt <= 0;
            blink_en  <= ~blink_en;
        end else begin
            blink_cnt <= blink_cnt + 1;
        end
    end

    // =====================================================
    // Multiplexação (~1 kHz por dígito)
    // =====================================================
    reg [15:0] mux_cnt = 0;
    reg [1:0]  digit   = 0;

    always @(posedge mclk) begin
        mux_cnt <= mux_cnt + 1;
        if (mux_cnt == 16'd50000) begin // 100MHz / 50k = 2 kHz
            mux_cnt <= 0;
            digit   <= digit + 1;
        end
    end

    // =====================================================
    // Controle dos anodos
    // =====================================================
    always @(*) begin
        if (!blink_en)
            D0_a = 4'b1111; // tudo desligado
        else begin
            case (digit)
                2'd3: D0_a = 4'b1110; // F
                2'd2: D0_a = 4'b1101; // P
                2'd1: D0_a = 4'b1011; // G
                2'd0: D0_a = 4'b0111; // A
                default: D0_a = 4'b1111;
            endcase
        end
    end

    // =====================================================
    // Segmentos por dígito
    // =====================================================
    always @(*) begin
        if (!blink_en)
            D0_seg = 8'b11111111;
        else begin
            case (digit)
                2'd3: D0_seg = 8'b10001110; // F
                2'd2: D0_seg = 8'b10001100; // P
                2'd1: D0_seg = 8'b10100000; // G
                2'd0: D0_seg = 8'b10001000; // A
                default: D0_seg = 8'b11111111;
            endcase
        end
    end

endmodule
