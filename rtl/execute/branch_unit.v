`timescale 1ns/1ps

// Decides whether a jump or conditional branch should update the PC.
module branch_unit (
    input  wire [3:0] operation,
    input  wire zero_flag,
    output wire taken
);
    reg branch_taken;

    always @* begin
        case (operation)
            4'd0: branch_taken = 1'b0;
            4'd1: branch_taken = 1'b1;
            4'd2: branch_taken = zero_flag;
            4'd3: branch_taken = !zero_flag;
            default: branch_taken = 1'b0;
        endcase
    end

    assign taken = branch_taken;
endmodule
