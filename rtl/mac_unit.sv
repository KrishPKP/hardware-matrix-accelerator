module MacUnit(
    //inputs
    input logic clk,
    input logic rst,
    input logic enable,
    input logic [7:0] A,
    input logic [7:0] B,
    //outputs
    output logic [17:0] accumulator); //lets say for 8bit by 8bit integers, for 4x4 matrices then 18 bit should be goood for the accumulator    
    //triggers exclusively on the rising edge of clock signal
    always_ff @(posedge clk) begin

        if (rst)
            accumulator <= 0;

        else if (enable)
            accumulator <= accumulator + A*B;
    end
        

endmodule
