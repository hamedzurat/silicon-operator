// Opcode 04: SUB writes the ALU result to a register.
module instruction_sub (
    input  wire [7:0] opcode,
    output wire [17:0] decoded
);
    localparam [2:0] WB_ALU = 3'd0;
    localparam [3:0] ALU_SUB = 4'd1;

    wire selected = (opcode == 8'h04);

    control_bus sub_controls (
        .active(selected),
        .register_write(1'b1),
        .ram_write(1'b0),
        .pin_write(1'b0),
        .flag_write(1'b0),
        .load(1'b0),
        .halt(1'b0),
        .writeback_source(WB_ALU),
        .alu_operation(ALU_SUB),
        .branch_operation(4'd0),
        .decoded(decoded)
    );
endmodule
