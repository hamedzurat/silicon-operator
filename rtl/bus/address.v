`timescale 1ns/1ps

// Selects the RAM word address: instruction fetch uses PC, data access uses a register.
module address_bus (
    input  wire [7:0] program_address,
    input  wire [7:0] register_address,
    input  wire       select_register,
    output wire [7:0] address
);
    assign address = select_register ? register_address : program_address;
endmodule
