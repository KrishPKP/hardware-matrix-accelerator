module MatrixMultSeq (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic [7:0] A [0:15],
    input  logic [7:0] B [0:15],

    output logic [15:0][17:0] C,
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

    logic [1:0] i, j, k;

    logic [7:0]  mac_A, mac_B;
    logic        mac_enable, mac_rst;
    logic [17:0] mac_accumulator;

    MacUnit mac (
        .clk(clk),
        .rst(mac_rst),
        .enable(mac_enable),
        .A(mac_A),
        .B(mac_B),
        .accumulator(mac_accumulator)
    );

    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

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
                if (k == 2'd3)
                    next_state = STORE;
            end

            STORE: begin
                if ((i == 2'd3) && (j == 2'd3))
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

    always_comb begin
        mac_rst    = rst;
        mac_enable = 1'b0;
        mac_A      = 8'd0;
        mac_B      = 8'd0;
        done       = 1'b0;

        case (state)
            CLEAR: begin
                mac_rst = 1'b1;
            end

            MAC: begin
                mac_enable = 1'b1;
                mac_A = A[{i, k}];
                mac_B = B[{k, j}];
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            i <= 2'd0;
            j <= 2'd0;
            k <= 2'd0;
            C <= '0;
        end
        else begin
            if ((state == IDLE) && start) begin
                i <= 2'd0;
                j <= 2'd0;
                k <= 2'd0;
            end
            else if (state == CLEAR) begin
                k <= 2'd0;
            end
            else if (state == MAC) begin
                if (k < 2'd3)
                    k <= k + 2'd1;
            end
            else if (state == STORE) begin
                C[{i, j}] <= mac_accumulator;

                if (j < 2'd3) begin
                    j <= j + 2'd1;
                end
                else if (i < 2'd3) begin
                    j <= 2'd0;
                    i <= i + 2'd1;
                end
            end
        end
    end

endmodule