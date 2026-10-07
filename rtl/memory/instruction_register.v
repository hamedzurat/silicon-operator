`timescale 1ns/1ps

module instruction_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        load,
    input  wire [31:0] data_in,
    output wire [7:0]  opcode,
    output wire [3:0]  rd,
    output wire [3:0]  rs,
    output wire [3:0]  rt,
    output wire [11:0] immediate
);
    reg [31:0] instruction;

    always @(posedge clk or posedge reset) begin
        if (reset)
            instruction <= 32'b0;
        else if (load)
            instruction <= data_in;
    end

    assign opcode = instruction[31:24];
    assign rd = instruction[23:20];
    assign rs = instruction[19:16];
    assign rt = instruction[15:12];
    assign immediate = instruction[11:0];
endmodule
