`timescale 1ns/1ps

module program_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire       load,
    input  wire [7:0] load_value,
    output reg  [7:0] value
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            value <= 8'b0;
        else if (enable) begin
            if (load)
                value <= load_value;
            else
                value <= value + 1'b1;
        end
    end
endmodule
