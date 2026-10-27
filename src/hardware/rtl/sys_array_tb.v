`include "systolic_array.v"

module sys_array_tb;

    localparam integer SIZE         = 16;
    localparam integer DATA_WIDTH   = 8;
    localparam integer RESULT_WIDTH = 20;
    localparam integer TOTAL_CYCLES = (3 * SIZE) - 2;

    reg clk;
    reg rst;
    reg [SIZE*DATA_WIDTH-1:0] inp_west;
    reg [SIZE*DATA_WIDTH-1:0] inp_north;
    reg [DATA_WIDTH-1:0] matriz_a [0:SIZE*SIZE-1];
    reg [DATA_WIDTH-1:0] matriz_b [0:SIZE*SIZE-1];

    integer ciclo;
    integer indice;
    integer linha;
    integer coluna;
    integer k;
    integer esperado;
    integer erros;
    wire done;

    systolic_array #(
        .SIZE         (SIZE),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESULT_WIDTH (RESULT_WIDTH)
    ) uut (
        .inp_west  (inp_west),
        .inp_north (inp_north),
        .clk       (clk),
        .rst       (rst),
        .done      (done)
    );

    // Em cada ciclo, injeta as 16 linhas de A pelo oeste e as 16 colunas
    // de B pelo norte. O deslocamento pelo indice alinha A[i][k] e B[k][j]
    // no PE (i,j), sem reduzir as matrizes para uma janela menor.
    task automatic atribuir_inputs;
        input integer ciclo_atual;
        integer linha_coluna;
        integer elemento;
        begin
            inp_west  = {SIZE*DATA_WIDTH{1'b0}};
            inp_north = {SIZE*DATA_WIDTH{1'b0}};

            for (linha_coluna = 0;
                 linha_coluna < SIZE;
                 linha_coluna = linha_coluna + 1) begin
                elemento = ciclo_atual - linha_coluna;

                if ((elemento >= 0) && (elemento < SIZE)) begin
                    inp_west[linha_coluna*DATA_WIDTH +: DATA_WIDTH] =
                        matriz_a[linha_coluna*SIZE + elemento];

                    inp_north[linha_coluna*DATA_WIDTH +: DATA_WIDTH] =
                        matriz_b[elemento*SIZE + linha_coluna];
                end
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst       = 1'b1;
        inp_west  = {SIZE*DATA_WIDTH{1'b0}};
        inp_north = {SIZE*DATA_WIDTH{1'b0}};
        erros     = 0;

        $readmemh("src/common/matrizA.txt", matriz_a);
        $readmemh("src/common/matrizB.txt", matriz_b);

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // 16 ciclos de dados e 30 ciclos para drenar a malha 16x16.
        for (ciclo = 0; ciclo < TOTAL_CYCLES; ciclo = ciclo + 1) begin
            atribuir_inputs(ciclo);
            @(posedge clk);
            @(negedge clk);
        end

        inp_west  = {SIZE*DATA_WIDTH{1'b0}};
        inp_north = {SIZE*DATA_WIDTH{1'b0}};

        // Confere todos os 256 elementos de C = A x B.
        for (linha = 0; linha < SIZE; linha = linha + 1) begin
            for (coluna = 0; coluna < SIZE; coluna = coluna + 1) begin
                esperado = 0;
                for (k = 0; k < SIZE; k = k + 1)
                    esperado = esperado
                             + matriz_a[linha*SIZE + k]
                             * matriz_b[k*SIZE + coluna];

                indice = ((linha*SIZE) + coluna) * RESULT_WIDTH;
                if (uut.results[indice +: RESULT_WIDTH] !==
                    esperado[RESULT_WIDTH-1:0]) begin
                    erros = erros + 1;
                    $display(
                        "ERRO C[%0d][%0d]: obtido=%0d esperado=%0d",
                        linha, coluna,
                        uut.results[indice +: RESULT_WIDTH], esperado
                    );
                end
            end
        end

        if (erros == 0)
            $display("PASS: multiplicacao 16x16 correta (256 resultados).");
        else
            $display("FAIL: %0d resultados incorretos.", erros);

        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sys_array_tb);
    end

endmodule
