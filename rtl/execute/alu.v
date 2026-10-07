`timescale 1ns/1ps

// ALU operation: 0=add, 1=subtract, 2=equal, 3=not equal.
module alu (
    input  wire [31:0] left,
    input  wire [31:0] right,
    input  wire [3:0]  operation,
    output reg  [31:0] result,
    output wire        equal
);
    assign equal = (left == right);

    always @* begin
        case (operation)
            4'd0: result = left + right;
            4'd1: result = left - right;
            4'd2: result = {31'b0, equal};
            4'd3: result = {31'b0, !equal};
            default: result = 32'b0;
        endcase
    end
endmodule
