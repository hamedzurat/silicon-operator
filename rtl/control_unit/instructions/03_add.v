// Opcode 03: ADD writes the ALU result to a register.
module instruction_add (
    input  wire [7:0] opcode,
    output wire [16:0] decoded
);
    localparam [2:0] WB_ALU = 3'd0;
    localparam [3:0] ALU_ADD = 4'd0;

    wire selected = (opcode == 8'h03);

    control_bus add_controls (
        .active(selected),
        .register_write(1'b1),
        .writeback_source(WB_ALU),
        .alu_operation(ALU_ADD),
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
