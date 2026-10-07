// Opcode FF: HALT stops the controller.
module instruction_halt (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    wire selected = (opcode == 8'hff);

    control_bus halt_controls (
        .active(selected),
        .register_write(1'b0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b1),
        .writeback_source(3'd0),
        .alu_operation(4'd0),
        .branch_operation(4'd0),
        .decoded(decoded)
    );
endmodule
