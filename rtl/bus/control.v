`timescale 1ns/1ps

// Packs individually named control wires into the control word.
module control_bus (
    input  wire active,
    input  wire register_write,
    input  wire ram_write,
    input  wire pin_write,
    input  wire flag_write,
    input  wire load,
    input  wire halt,
    input  wire [2:0] writeback_source,
    input  wire [3:0] alu_operation,
    input  wire [3:0] branch_operation,
    output wire [17:0] decoded
);
    wire [16:0] requested_controls = {
        halt,
        load,
        flag_write,
        pin_write,
        ram_write,
        register_write,
        branch_operation,
        alu_operation,
        writeback_source
    };

    assign decoded = {active, active ? requested_controls : 17'b0};
endmodule
