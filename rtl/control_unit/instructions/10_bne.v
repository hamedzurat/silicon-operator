// Opcode 10: BNE branches when the zero flag is clear.
module instruction_bne (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [3:0] BRANCH_NOT_EQUAL = 4'd3;

    wire selected = (opcode == 8'h0a);

    control_bus bne_controls (
        .active(selected),
        .register_write(1'b0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b0),
        .writeback_source(3'd0),
        .alu_operation(4'd0),
        .branch_operation(BRANCH_NOT_EQUAL),
        .decoded(decoded)
    );
endmodule
