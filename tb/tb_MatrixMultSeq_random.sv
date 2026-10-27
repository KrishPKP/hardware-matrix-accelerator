`timescale 1ns/1ps

module tb_MatrixMultSeq_random;

    localparam int N = 4;
    localparam int DATA_WIDTH = 8;
    localparam int ACC_WIDTH =
        (2 * DATA_WIDTH) + $clog2(N);

    localparam int NUM_TESTS = 100;

    logic clk;
    logic rst;
    logic start;

    logic [DATA_WIDTH-1:0] A [0:N*N-1];
    logic [DATA_WIDTH-1:0] B [0:N*N-1];

    logic [N*N-1:0][ACC_WIDTH-1:0] C;
    logic done;

    logic [ACC_WIDTH-1:0] expected [0:N*N-1];

    integer a_file;
    integer b_file;
    integer expected_file;

    integer test;
    integer n;
    integer status;


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
        #100000;
        $fatal(1, "FAILED: simulation timed out");
    end


    initial begin

        rst = 1'b1;
        start = 1'b0;


        // Open test-vector files
        a_file = $fopen("software/A.txt", "r");
        b_file = $fopen("software/B.txt", "r");
        expected_file = $fopen("software/expected.txt", "r");


        if (a_file == 0)
            $fatal(1, "Could not open A.txt");

        if (b_file == 0)
            $fatal(1, "Could not open B.txt");

        if (expected_file == 0)
            $fatal(1, "Could not open expected.txt");


        // Reset DUT
        @(posedge clk);
        #1;
        rst = 1'b0;


        // Run all tests
        for (test = 0; test < NUM_TESTS; test = test + 1) begin

            // Read matrix A
            for (n = 0; n < N*N; n = n + 1) begin
                status = $fscanf(a_file, "%d", A[n]);

                if (status != 1)
                    $fatal(1, "Failed reading A for test %0d", test);
            end


            // Read matrix B
            for (n = 0; n < N*N; n = n + 1) begin
                status = $fscanf(b_file, "%d", B[n]);

                if (status != 1)
                    $fatal(1, "Failed reading B for test %0d", test);
            end


            // Read expected result
            for (n = 0; n < N*N; n = n + 1) begin
                status = $fscanf(
                    expected_file,
                    "%d",
                    expected[n]
                );

                if (status != 1)
                    $fatal(
                        1,
                        "Failed reading expected C for test %0d",
                        test
                    );
            end


            // Start DUT
            start = 1'b1;

            @(posedge clk);
            #1;

            start = 1'b0;


            // Wait for matrix multiplication to finish
            wait(done == 1'b1);
            #1;


            // Compare every output
            for (n = 0; n < N*N; n = n + 1) begin

                if (C[n] !== expected[n]) begin

                    $fatal(
                        1,
                        "TEST %0d FAILED: C[%0d] expected %0d, got %0d",
                        test,
                        n,
                        expected[n],
                        C[n]
                    );

                end

            end


            $display("Test %0d PASSED", test);


            // Allow DUT to leave DONE and return to IDLE
            @(posedge clk);
            #1;

        end


        $display("--------------------------------");
        $display("ALL %0d RANDOM TESTS PASSED", NUM_TESTS);
        $display("--------------------------------");


        $fclose(a_file);
        $fclose(b_file);
        $fclose(expected_file);

        $finish;

    end

endmodule