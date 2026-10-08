`timescale 1ns/1ps

// Read-only instruction memory addressed by the program counter.
module rom (
    input  wire [7:0]  address,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:255];
    reg [31:0] program_word;

`ifdef SIMULATION
    initial $readmemh("tb/program.hex", mem);
    assign read_data = mem[address];
`else
    // Fixed program image for synthesis. Unused addresses contain HALT.
    always @* begin
        case (address)
            8'h00: program_word = 32'h00000000;
            8'h01: program_word = 32'h01100014;
            8'h02: program_word = 32'h01200007;
            8'h03: program_word = 32'h02310000;
            8'h04: program_word = 32'h0c030000;
            8'h05: program_word = 32'h04412000;
            8'h06: program_word = 32'h0c040000;
            8'h07: program_word = 32'h03522000;
            8'h08: program_word = 32'h0c050000;
            8'h09: program_word = 32'h05013000;
            8'h0a: program_word = 32'h0900000c;
            8'h0b: program_word = 32'hff000000;
            8'h0c: program_word = 32'h05012000;
            8'h0d: program_word = 32'h0900000f;
            8'h0e: program_word = 32'h0160000a;
            8'h0f: program_word = 32'h0a000011;
            8'h10: program_word = 32'hff000000;
            8'h11: program_word = 32'h0c060000;
            8'h12: program_word = 32'h05013000;
            8'h13: program_word = 32'h0a000015;
            8'h14: program_word = 32'h00000000;
            8'h15: program_word = 32'h08000017;
            8'h16: program_word = 32'hff000000;
            8'h17: program_word = 32'h018000c8;
            8'h18: program_word = 32'h01900321;
            8'h19: program_word = 32'h07098000;
            8'h1a: program_word = 32'h06a80000;
            8'h1b: program_word = 32'h0c0a0000;
            8'h1c: program_word = 32'h0bb00000;
            8'h1d: program_word = 32'h0c0b0000;
            8'h1e: program_word = 32'h01c00fff;
            8'h1f: program_word = 32'h03dc2000;
            8'h20: program_word = 32'h0c0d0000;
            8'h21: program_word = 32'hff000000;
            default: program_word = 32'hff000000;
        endcase
    end
    assign read_data = program_word;
`endif
endmodule
