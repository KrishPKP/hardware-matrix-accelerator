module MatrixMultSeq #(
    parameter int N = 4,
    parameter int DATA_WIDTH = 8,

    parameter int INDEX_WIDTH =
        (N <= 1) ? 1 : $clog2(N),

    parameter int ACC_WIDTH =
        (2 * DATA_WIDTH) + $clog2(N)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic [DATA_WIDTH-1:0] A [0:N*N-1],
    input  logic [DATA_WIDTH-1:0] B [0:N*N-1],

    output logic [N*N-1:0][ACC_WIDTH-1:0] C,
    output logic done
);

    typedef enum logic [2:0] {
        IDLE,
        CLEAR,
        MAC,
        STORE,
        DONE
    } state_t;

    state_t state, next_state;

    logic [INDEX_WIDTH-1:0] i;
    logic [INDEX_WIDTH-1:0] j;
    logic [INDEX_WIDTH-1:0] k;

    logic [DATA_WIDTH-1:0] mac_A;
    logic [DATA_WIDTH-1:0] mac_B;

    logic mac_enable;
    logic mac_rst;

    logic [ACC_WIDTH-1:0] mac_accumulator;


    MacUnit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) mac (
        .clk(clk),
        .rst(mac_rst),
        .enable(mac_enable),
        .A(mac_A),
        .B(mac_B),
        .accumulator(mac_accumulator)
    );


    // State register
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end


    // Next-state logic
    always_comb begin
        next_state = state;

        case (state)

            IDLE: begin
                if (start)
                    next_state = CLEAR;
            end

            CLEAR: begin
                next_state = MAC;
            end

            MAC: begin
                if (k == N - 1)
                    next_state = STORE;
            end

            STORE: begin
                if ((i == N - 1) && (j == N - 1))
                    next_state = DONE;
                else
                    next_state = CLEAR;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end


    // Datapath control
    always_comb begin
        mac_rst    = rst;
        mac_enable = 1'b0;
        mac_A      = '0;
        mac_B      = '0;
        done       = 1'b0;

        case (state)

            CLEAR: begin
                mac_rst = 1'b1;
            end

            MAC: begin
                mac_enable = 1'b1;

                mac_A = A[(i * N) + k];
                mac_B = B[(k * N) + j];
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
            end

        endcase
    end


    // Counters and result storage
    always_ff @(posedge clk) begin

        if (rst) begin
            i <= '0;
            j <= '0;
            k <= '0;
            C <= '0;
        end

        else begin

            if ((state == IDLE) && start) begin
                i <= '0;
                j <= '0;
                k <= '0;
            end

            else if (state == CLEAR) begin
                k <= '0;
            end

            else if (state == MAC) begin
                if (k < N - 1)
                    k <= k + 1'b1;
            end

            else if (state == STORE) begin

                C[(i * N) + j] <= mac_accumulator;

                if (j < N - 1) begin
                    j <= j + 1'b1;
                end

                else if (i < N - 1) begin
                    j <= '0;
                    i <= i + 1'b1;
                end

            end

        end
    end

endmodule