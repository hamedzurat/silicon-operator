// Opcode 09: BEQ branches when the zero flag is set.
module instruction_beq (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [3:0] BRANCH_EQUAL = 4'd2;

    wire selected = (opcode == 8'h09);

    control_bus beq_controls (
        .active(selected),
        .register_write(1'b0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b0),
        .writeback_source(3'd0),
        .alu_operation(4'd0),
        .branch_operation(BRANCH_EQUAL),
        .decoded(decoded)
    );
endmodule
