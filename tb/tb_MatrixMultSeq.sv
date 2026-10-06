//`include "MatrixMultSeq.sv"  
//for edaplayground use the import

module tb_MatrixMultSeq;

    logic clk;
    logic rst;
    logic start;

    logic [7:0] A [0:3];
    logic [7:0] B [0:3];

    logic [3:0][17:0] C;
    logic done;


    // DUT
    MatrixMultSeq dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );
  
  always @(posedge clk) begin
    #1;

    $display(
        "time=%0t state=%0d index=%0d mac_rst=%b enable=%b A=%0d B=%0d acc=%0d C=%0d,%0d,%0d,%0d",
        $time,
        dut.state,
        dut.output_index,
        dut.mac_rst,
        dut.mac_enable,
        dut.mac_A,
        dut.mac_B,
        dut.mac_accumulator,
        C[0], C[1], C[2], C[3]
    );
end
  


    // 100 MHz clock
    initial begin
        clk = 0;

        forever begin
            #5 clk = ~clk;
        end
    end


    // Test sequence
    initial begin

        // Initial values
        rst = 1;
        start = 0;

        A[0] = 0;
        A[1] = 0;
        A[2] = 0;
        A[3] = 0;

        B[0] = 0;
        B[1] = 0;
        B[2] = 0;
        B[3] = 0;


        // Reset DUT
        @(posedge clk);
        #1;

        rst = 0;


        // Matrix A
        //
        // | 1  2 |
        // | 3  4 |
        A[0] = 1;
        A[1] = 2;
        A[2] = 3;
        A[3] = 4;


        // Matrix B
        //
        // | 5  6 |
        // | 7  8 |
        B[0] = 5;
        B[1] = 6;
        B[2] = 7;
        B[3] = 8;


        // Start multiplication
        start = 1;

        @(posedge clk);
        #1;

        start = 0;


        // Wait until hardware is finished
        wait(done == 1);

        #1;


        // Check results
        //
        // Expected:
        //
        // | 19  22 |
        // | 43  50 |

        if (C[0] == 18'd19)
            $display("C00 PASSED: %0d", C[0]);
        else
            $display("C00 FAILED: expected 19, got %0d", C[0]);


        if (C[1] == 18'd22)
            $display("C01 PASSED: %0d", C[1]);
        else
            $display("C01 FAILED: expected 22, got %0d", C[1]);


        if (C[2] == 18'd43)
            $display("C10 PASSED: %0d", C[2]);
        else
            $display("C10 FAILED: expected 43, got %0d", C[2]);


        if (C[3] == 18'd50)
            $display("C11 PASSED: %0d", C[3]);
        else
            $display("C11 FAILED: expected 50, got %0d", C[3]);


        // Overall result
        if (
            C[0] == 18'd19 &&
            C[1] == 18'd22 &&
            C[2] == 18'd43 &&
            C[3] == 18'd50
        )
            $display("ALL MATRIX MULTIPLICATION TESTS PASSED");
        else
            $display("MATRIX MULTIPLICATION TEST FAILED");


        $finish;

    end

endmodule