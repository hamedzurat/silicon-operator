// Opcode 01: MOVI writes the sign-extended immediate to a register.
module instruction_movi (
    input  wire [7:0] opcode,
    output wire [16:0] decoded
);
    localparam [2:0] WB_IMMEDIATE = 3'd2;

    wire selected = (opcode == 8'h01);

    control_bus movi_controls (
        .active(selected),
        .register_write(1'b1),
        .writeback_source(WB_IMMEDIATE),
        .alu_operation(4'd0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .jump(1'b0),
        .branch_equal(1'b0),
        .branch_not_equal(1'b0),
        .halt(1'b0),
        .decoded(decoded)
    );
endmodule
