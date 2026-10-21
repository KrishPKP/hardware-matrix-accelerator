`timescale 1ns/1ps

module tb_MatrixMultSeq;

    logic clk;
    logic rst;
    logic start;

    logic [7:0] A [0:15];
    logic [7:0] B [0:15];
    logic [15:0][17:0] C;
    logic done;

    logic [17:0] expected [0:15];

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
        #5000;
        $fatal(1, "FAILED: simulation timed out");
    end

    initial begin
        rst = 1'b1;
        start = 1'b0;

        // Matrix A
        A[0]  = 1;
        A[1]  = 2;
        A[2]  = 3;
        A[3]  = 4;

        A[4]  = 5;
        A[5]  = 6;
        A[6]  = 7;
        A[7]  = 8;

        A[8]  = 9;
        A[9]  = 10;
        A[10] = 11;
        A[11] = 12;

        A[12] = 13;
        A[13] = 14;
        A[14] = 15;
        A[15] = 16;


        // Matrix B
        B[0]  = 16;
        B[1]  = 15;
        B[2]  = 14;
        B[3]  = 13;

        B[4]  = 12;
        B[5]  = 11;
        B[6]  = 10;
        B[7]  = 9;

        B[8]  = 8;
        B[9]  = 7;
        B[10] = 6;
        B[11] = 5;

        B[12] = 4;
        B[13] = 3;
        B[14] = 2;
        B[15] = 1;


        // Expected C
        expected[0]  = 80;
        expected[1]  = 70;
        expected[2]  = 60;
        expected[3]  = 50;

        expected[4]  = 240;
        expected[5]  = 214;
        expected[6]  = 188;
        expected[7]  = 162;

        expected[8]  = 400;
        expected[9]  = 358;
        expected[10] = 316;
        expected[11] = 274;

        expected[12] = 560;
        expected[13] = 502;
        expected[14] = 444;
        expected[15] = 386;


        // Reset
        @(posedge clk);
        #1;
        rst = 1'b0;


        // Start
        start = 1'b1;
        @(posedge clk);
        #1;
        start = 1'b0;


        // Wait for result
        wait(done == 1'b1);
        #1;


        // Check all 16 outputs
        for (n = 0; n < 16; n = n + 1) begin
            if (C[n] !== expected[n]) begin
                $fatal(
                    1,
                    "FAILED: C[%0d] expected %0d, got %0d",
                    n,
                    expected[n],
                    C[n]
                );
            end
        end

        $display("ALL 4x4 NONTRIVIAL TESTS PASSED");
        $finish;
    end

endmodule