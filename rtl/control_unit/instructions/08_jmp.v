// Opcode 08: JMP loads an absolute address into the program counter.
module instruction_jmp (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [3:0] BRANCH_JUMP = 4'd1;

    wire selected = (opcode == 8'h08);

    control_bus jump_controls (
        .active(selected),
        .register_write(1'b0),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b0),
        .writeback_source(3'd0),
        .alu_operation(4'd0),
        .branch_operation(BRANCH_JUMP),
        .decoded(decoded)
    );
endmodule
