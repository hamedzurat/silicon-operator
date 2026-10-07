`timescale 1ns/1ps

// Packs individually named control wires into the control word.
module control_bus (
    input  wire active,
    input  wire register_write,
    input  wire [2:0] writeback_source,
    input  wire [3:0] alu_operation,
    input  wire ram_write,
    input  wire pin_write,
    input  wire flag_write,
    input  wire load,
    input  wire jump,
    input  wire branch_equal,
    input  wire branch_not_equal,
    input  wire halt,
    output wire [16:0] decoded
);
    wire [15:0] requested_controls = {
        halt,
        branch_not_equal,
        branch_equal,
        jump,
        load,
        flag_write,
        pin_write,
        ram_write,
        alu_operation,
        writeback_source,
        register_write
    };

    assign decoded = {active, active ? requested_controls : 16'b0};
endmodule
