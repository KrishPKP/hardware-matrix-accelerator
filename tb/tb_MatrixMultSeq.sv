`timescale 1ns/1ps

module tb_MatrixMultSeq;

    localparam int N = 2;
    localparam int DATA_WIDTH = 8;
    localparam int ACC_WIDTH =
        (2 * DATA_WIDTH) + $clog2(N);

    logic clk;
    logic rst;
    logic start;

    logic [DATA_WIDTH-1:0] A [0:N*N-1];
    logic [DATA_WIDTH-1:0] B [0:N*N-1];

    logic [N*N-1:0][ACC_WIDTH-1:0] C;
    logic done;

    logic [ACC_WIDTH-1:0] expected [0:N*N-1];

    integer n;


    MatrixMultSeq #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );


    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // Timeout
    initial begin
        #5000;
        $fatal(1, "FAILED: simulation timed out");
    end


    // Test
    initial begin

        rst = 1'b1;
        start = 1'b0;


        // A =
        // | 1  2 |
        // | 3  4 |

        A[0] = 1;
        A[1] = 2;
        A[2] = 3;
        A[3] = 4;


        // B =
        // | 5  6 |
        // | 7  8 |

        B[0] = 5;
        B[1] = 6;
        B[2] = 7;
        B[3] = 8;


        // Expected C =
        // | 19  22 |
        // | 43  50 |

        expected[0] = 19;
        expected[1] = 22;
        expected[2] = 43;
        expected[3] = 50;


        // Reset
        @(posedge clk);
        #1;
        rst = 1'b0;


        // Start multiplication
        start = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;


        // Wait until complete
        wait(done == 1'b1);
        #1;


        // Check outputs
        for (n = 0; n < N*N; n = n + 1) begin

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


        $display("ALL 2x2 TESTS PASSED");
        $finish;

    end

endmodule