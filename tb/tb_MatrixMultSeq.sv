`timescale 1ns/1ps

module tb_MatrixMultSeq;

    logic clk;
    logic rst;
    logic start;

    logic [7:0] A [0:15];
    logic [7:0] B [0:15];
    logic [15:0][17:0] C;
    logic done;

    integer n;

    MatrixMultSeq dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        start = 1'b0;

        for (n = 0; n < 16; n = n + 1) begin
            A[n] = n + 1;
            B[n] = 8'd0;
        end

        B[0]  = 1;
        B[5]  = 1;
        B[10] = 1;
        B[15] = 1;

        @(posedge clk);
        #1;
        rst = 1'b0;

        start = 1'b1;
        @(posedge clk);
        #1;
        start = 1'b0;

        wait(done == 1'b1);
        #1;

        for (n = 0; n < 16; n = n + 1) begin
            if (C[n] !== (n + 1)) begin
                $display("FAILED: C[%0d] expected %0d, got %0d", n, n + 1, C[n]);
                $finish;
            end
        end

        $display("ALL 4x4 IDENTITY TESTS PASSED");
        $finish;
    end

endmodule
