// Opcode 12: OUT copies a register's low 16 bits to the output pins.
module instruction_out (
    input  wire [7:0] opcode,
    output wire [16:0] decoded
);
    wire selected = (opcode == 8'h0c);

    control_bus out_controls (
        .active(selected),
        .register_write(1'b0),
        .writeback_source(3'd0),
        .alu_operation(4'd0),
        .ram_write(1'b0),
        .pin_write(1'b1),
        .flag_write(1'b0),
        .load(1'b0),
        .jump(1'b0),
        .branch_equal(1'b0),
        .branch_not_equal(1'b0),
        .halt(1'b0),
        .decoded(decoded)
    );
endmodule
