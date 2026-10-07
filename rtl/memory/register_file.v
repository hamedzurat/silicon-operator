`timescale 1ns/1ps

module register_file (
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  source_a_index,
    input  wire [3:0]  source_b_index,
    output wire [31:0] source_a_value,
    output wire [31:0] source_b_value,
    input  wire        write_enable,
    input  wire [3:0]  write_address,
    input  wire [31:0] write_data
);
    reg [31:0] registers [0:15];
    integer i;

    // Two independent read paths let the ALU receive both operands at once.
    assign source_a_value = registers[source_a_index];
    assign source_b_value = registers[source_b_index];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1)
                registers[i] <= 32'b0;
        end else if (write_enable) begin
            registers[write_address] <= write_data;
        end
    end
endmodule
