// Opcode 05: CMP writes the ALU equality result into the zero flag.
module instruction_cmp (
    input  wire [7:0] opcode,
    output wire [16:0] decoded
);
    localparam [3:0] ALU_EQUAL = 4'd2;

    wire selected = (opcode == 8'h05);

    control_bus cmp_controls (
        .active(selected),
        .register_write(1'b0),
        .writeback_source(3'd0),
        .alu_operation(ALU_EQUAL),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b1),
        .load(1'b0),
        .jump(1'b0),
        .branch_equal(1'b0),
        .branch_not_equal(1'b0),
        .halt(1'b0),
        .decoded(decoded)
    );
endmodule
