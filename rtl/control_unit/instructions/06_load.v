// Opcode 06: LOAD reads RAM into a register.
module instruction_load (
    input  wire [7:0] opcode,
    output wire [16:0] decoded
);
    localparam [2:0] WB_RAM = 3'd1;

    wire selected = (opcode == 8'h06);

    control_bus load_controls (
        .active(selected),
        .register_write(1'b1),
        .writeback_source(WB_RAM),
        .alu_operation(4'd0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b1),
        .jump(1'b0),
        .branch_equal(1'b0),
        .branch_not_equal(1'b0),
        .halt(1'b0),
        .decoded(decoded)
    );
endmodule
