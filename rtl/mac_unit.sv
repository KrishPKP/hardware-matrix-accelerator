module MacUnit #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH = 18
)(
    input  logic clk,
    input  logic rst,
    input  logic enable,

    input  logic [DATA_WIDTH-1:0] A,
    input  logic [DATA_WIDTH-1:0] B,

    output logic [ACC_WIDTH-1:0] accumulator
);

    always_ff @(posedge clk) begin
        if (rst)
            accumulator <= '0;
        else if (enable)
            accumulator <= accumulator + (A * B);
    end

endmodule