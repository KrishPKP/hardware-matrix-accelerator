module tb_MacUnit;

    logic clk;
    logic rst;
    logic enable;
    logic [7:0] A;
    logic [7:0] B;

    logic [17:0] accumulator;

    MacUnit dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .A(A),
        .B(B),
        .accumulator(accumulator)
    );

    // Generate 100 MHz clock
    initial begin
        clk = 0;

        forever begin
            #5 clk = ~clk;
        end
    end

    // Run tests
    initial begin

        // Initial values
        rst = 1;
        enable = 0;
        A = 0;
        B = 0;

        // Test 1: Reset
        @(posedge clk);
        #1;

        if (accumulator == 0)
            $display("TEST 1 PASSED: Reset");
        else
            $display("TEST 1 FAILED: Expected 0, got %d", accumulator);

        rst = 0;

        // Test 2: 3 * 4 = 12
        A = 3;
        B = 4;
        enable = 1;

        @(posedge clk);
        #1;
        if (accumulator == 12)
            $display("TEST 2 PASSED: accumulator = 12");
        else
            $display("TEST 2 FAILED: Expected 12, got %d", accumulator);


        // Test 3: 12 + 2 * 5 = 22
        A = 2;
        B = 5;

        @(posedge clk);
        #1;
        if (accumulator == 22)
            $display("TEST 3 PASSED: accumulator = 22");
        else
            $display("TEST 3 FAILED: Expected 22, got %d", accumulator);


        // Test 4: Disable
        // acc shouldd hold 22
        enable = 0;
        A = 50;
        B = 50;

        @(posedge clk);
        #1;
        if (accumulator == 22)
            $display("TEST 4 PASSED: enable holds accumulator");
        else
            $display("TEST 4 FAILED: Expected 22, got %d", accumulator);

        // Test 5: Reset
        rst = 1;
        @(posedge clk);
        #1;
        if (accumulator == 0)
            $display("TEST 5 PASSED: Reset returned accumulator to 0");
        else
            $display("TEST 5 FAILED: Expected 0, got %d", accumulator);

        $display("Simulation complete.");
        $finish;

    end

endmodule