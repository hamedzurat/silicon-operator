`timescale 1ns/1ps

module ram (
    input  wire        clk,
    input  wire [7:0]  address,
    input  wire [31:0] write_data,
    input  wire        write_enable,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:255];
    assign read_data = mem[address];

    always @(posedge clk) begin
        if (write_enable)
            mem[address] <= write_data;
    end
endmodule
