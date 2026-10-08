`timescale 1ns/1ps

// Read-only instruction memory addressed by the program counter.
module rom (
    input  wire [7:0]  address,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:255];
    initial $readmemh("tb/program.hex", mem);
    assign read_data = mem[address];
endmodule
