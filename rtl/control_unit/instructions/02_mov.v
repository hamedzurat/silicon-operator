// Opcode 02: MOV copies one register value to another.
module instruction_mov (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [2:0] WB_REGISTER = 3'd4;

    wire selected = (opcode == 8'h02);

    control_bus mov_controls (
        .active(selected),
        .register_write(1'b1),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b0),
        .writeback_source(WB_REGISTER),
        .alu_operation(4'd0),
        .branch_operation(4'd0),
        .decoded(decoded)
    );
endmodule
