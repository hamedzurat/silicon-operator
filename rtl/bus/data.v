`timescale 1ns/1ps

// 32-bit register writeback path. The selector chooses one of five data sources.
module data_bus (
    input  wire [31:0] alu_value,
    input  wire [31:0] memory_value,
    input  wire [31:0] immediate_value,
    input  wire [31:0] input_value,
    input  wire [31:0] register_value,
    input  wire [2:0]  select,
    output reg  [31:0] value
);
    always @* begin
        case (select)
            3'd0: value = alu_value;
            3'd1: value = memory_value;
            3'd2: value = immediate_value;
            3'd3: value = input_value;
            3'd4: value = register_value;
            default: value = 32'b0;
        endcase
    end
endmodule
