module MatrixMultSeq(

    // Inputs
    input logic clk,
    input logic rst,
    input logic start,

    input logic [7:0] A [0:3],
    input logic [7:0] B [0:3],

    // Outputs
    output logic [3:0][17:0] C,
    output logic done
);

    // FSM states

    typedef enum logic [2:0] {
        IDLE,
        CLEAR,
        MAC1,
        MAC2,
        STORE,
        DONE
    } state_t;

    state_t state;
    state_t next_state;


    logic [1:0] output_index;


    // Signals connected to the MAC
    logic [7:0] mac_A;
    logic [7:0] mac_B;

    logic mac_enable;
    logic mac_rst;

    logic [17:0] mac_accumulator;


    // Instantiate the MAC unit
 
    MacUnit mac (
        .clk(clk),
        .rst(mac_rst),
        .enable(mac_enable),
        .A(mac_A),
        .B(mac_B),
        .accumulator(mac_accumulator)
    );


    // STATE REGISTER
    // Stores the current FSM state & it only changes on a rising clock edge.

    always_ff @(posedge clk) begin

        if (rst)
            state <= IDLE;

        else
            state <= next_state;

    end


    // NEXT-STATE LOGIC
    // Determines where the FSM should go next.

    always_comb begin

        // Default: stay where we are
        next_state = state;

        case (state)

            IDLE: begin
                if (start)
                    next_state = CLEAR;
            end


            CLEAR: begin
                next_state = MAC1;
            end


            MAC1: begin
                next_state = MAC2;
            end


            MAC2: begin
                next_state = STORE;
            end


            STORE: begin

                // calcd all four outputs
                if (output_index == 2'd3)
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


    // FSM OUTPUT / DATAPATH CONTROL LOGIC
    // Determines what the MAC should do
    // during each state.

    always_comb begin

        // Defaults
        mac_rst    = rst;
        mac_enable = 0;

        mac_A = 0;
        mac_B = 0;

        done = 0;


        case (state)

            IDLE: begin
                // Nothing happening
            end


            CLEAR: begin

                // Clear MAC accumulator before
                // calculating a new C element
                mac_rst = 1;

            end


            MAC1: begin

                mac_enable = 1;

                case (output_index)

                    // C00 = A00*B00 + A01*B10
                    2'd0: begin
                        mac_A = A[0];
                        mac_B = B[0];
                    end

                    // C01 = A00*B01 + A01*B11
                    2'd1: begin
                        mac_A = A[0];
                        mac_B = B[1];
                    end

                    // C10 = A10*B00 + A11*B10
                    2'd2: begin
                        mac_A = A[2];
                        mac_B = B[0];
                    end

                    // C11 = A10*B01 + A11*B11
                    2'd3: begin
                        mac_A = A[2];
                        mac_B = B[1];
                    end

                endcase

            end


            MAC2: begin

                mac_enable = 1;

                case (output_index)

                    // C00
                    2'd0: begin
                        mac_A = A[1];
                        mac_B = B[2];
                    end

                    // C01
                    2'd1: begin
                        mac_A = A[1];
                        mac_B = B[3];
                    end

                    // C10
                    2'd2: begin
                        mac_A = A[3];
                        mac_B = B[2];
                    end

                    // C11
                    2'd3: begin
                        mac_A = A[3];
                        mac_B = B[3];
                    end

                endcase

            end


            STORE: begin
                // MAC disabled while we save result
            end


            DONE: begin
                done = 1;
            end

        endcase

    end


    // OUTPUT / INDEX REGISTERS

    always_ff @(posedge clk) begin

        if (rst) begin

            output_index <= 0;

            C[0] <= 0;
            C[1] <= 0;
            C[2] <= 0;
            C[3] <= 0;

        end

        else begin

            // Starting a new multiplication
            if (state == IDLE && start)
                output_index <= 0;


            // Save completed MAC result
            if (state == STORE) begin

                C[output_index] <= mac_accumulator;

                if (output_index != 2'd3)
                    output_index <= output_index + 1;

            end

        end

    end


endmodule