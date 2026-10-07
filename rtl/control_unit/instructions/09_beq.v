// Opcode 09: BEQ branches when the zero flag is set.
module instruction_beq (
    input  wire [7:0] opcode,
    output wire [16:0] decoded
);
    wire selected = (opcode == 8'h09);

    control_bus beq_controls (
        .active(selected),
        .register_write(1'b0),
        .writeback_source(3'd0),
        .alu_operation(4'd0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .jump(1'b0),
        .branch_equal(1'b1),
        .branch_not_equal(1'b0),
        .halt(1'b0),
        .decoded(decoded)
    );
endmodule
