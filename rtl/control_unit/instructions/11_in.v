// Opcode 11: IN writes the fixed input pins to a register.
module instruction_in (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [2:0] WB_INPUT = 3'd3;

    wire selected = (opcode == 8'h0b);

    control_bus in_controls (
        .active(selected),
        .register_write(1'b1),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b0),
        .writeback_source(WB_INPUT),
        .alu_operation(4'd0),
        .branch_operation(4'd0),
        .decoded(decoded)
    );
endmodule
