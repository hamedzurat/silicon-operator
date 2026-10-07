// Opcode 06: LOAD reads RAM into a register.
module instruction_load (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [2:0] WB_RAM = 3'd1;

    wire selected = (opcode == 8'h06);

    control_bus load_controls (
        .active(selected),
        .register_write(1'b1),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b1),
        .halt(1'b0),
        .writeback_source(WB_RAM),
        .alu_operation(4'd0),
        .branch_operation(4'd0),
        .decoded(decoded)
    );
endmodule
