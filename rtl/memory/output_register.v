`timescale 1ns/1ps

module output_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        write_enable,
    input  wire [15:0] write_data,
    output reg  [15:0] value
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            value <= 16'b0;
        else if (write_enable)
            value <= write_data;
    end
endmodule
