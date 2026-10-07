`timescale 1ns/1ps

// Read-only instruction memory addressed by the program counter.
module rom #(
    parameter INIT_FILE = ""
) (
    input  wire [7:0]  address,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:255];

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    assign read_data = mem[address];
endmodule
