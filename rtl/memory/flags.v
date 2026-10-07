`timescale 1ns/1ps

// Architectural status storage. More flags can be added here as the ISA grows.
module flags (
    input  wire clk,
    input  wire reset,
    input  wire write_zero,
    input  wire zero_in,
    output reg  zero
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            zero <= 1'b0;
        else if (write_zero)
            zero <= zero_in;
    end
endmodule
