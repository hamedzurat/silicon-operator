`timescale 1ns/1ps

// Decodes an opcode and packs its controls with control_bus.
module instruction_decoder (
    input  wire [7:0] opcode,
    output wire recognized,
    output wire [16:0] controls
);
    localparam [2:0] WB_ALU = 3'd0;
    localparam [2:0] WB_RAM = 3'd1;
    localparam [2:0] WB_IMMEDIATE = 3'd2;
    localparam [2:0] WB_INPUT = 3'd3;
    localparam [2:0] WB_REGISTER = 3'd4;

    localparam [3:0] ALU_ADD = 4'd0;
    localparam [3:0] ALU_SUBTRACT = 4'd1;
    localparam [3:0] ALU_EQUAL = 4'd2;

    localparam [3:0] BRANCH_JUMP = 4'd1;
    localparam [3:0] BRANCH_EQUAL = 4'd2;
    localparam [3:0] BRANCH_NOT_EQUAL = 4'd3;

    reg active;
    reg register_write;
    reg ram_write;
    reg pin_write;
    reg flag_write;
    reg load;
    reg halt;
    reg [2:0] writeback_source;
    reg [3:0] alu_operation;
    reg [3:0] branch_operation;
    wire [17:0] decoded;

    always @* begin
        active = 1'b1;
        register_write = 1'b0;
        ram_write = 1'b0;
        pin_write = 1'b0;
        flag_write = 1'b0;
        load = 1'b0;
        halt = 1'b0;
        writeback_source = WB_ALU;
        alu_operation = ALU_ADD;
        branch_operation = 4'd0;

        case (opcode)
            8'h00: begin // NOP
            end
            8'h01: begin // MOVI
                register_write = 1'b1;
                writeback_source = WB_IMMEDIATE;
            end
            8'h02: begin // MOV
                register_write = 1'b1;
                writeback_source = WB_REGISTER;
            end
            8'h03: begin // ADD
                register_write = 1'b1;
                writeback_source = WB_ALU;
                alu_operation = ALU_ADD;
            end
            8'h04: begin // SUB
                register_write = 1'b1;
                writeback_source = WB_ALU;
                alu_operation = ALU_SUBTRACT;
            end
            8'h05: begin // CMP
                flag_write = 1'b1;
                alu_operation = ALU_EQUAL;
            end
            8'h06: begin // LOAD
                register_write = 1'b1;
                writeback_source = WB_RAM;
                load = 1'b1;
            end
            8'h07: begin // STORE
                ram_write = 1'b1;
            end
            8'h08: begin // JMP
                branch_operation = BRANCH_JUMP;
            end
            8'h09: begin // BEQ
                branch_operation = BRANCH_EQUAL;
            end
            8'h0a: begin // BNE
                branch_operation = BRANCH_NOT_EQUAL;
            end
            8'h0b: begin // IN
                register_write = 1'b1;
                writeback_source = WB_INPUT;
            end
            8'h0c: begin // OUT
                pin_write = 1'b1;
            end
            8'hff: begin // HALT
                halt = 1'b1;
            end
            default: begin
                active = 1'b0;
            end
        endcase
    end

    control_bus control_word (
        .active(active),
        .register_write(register_write),
        .ram_write(ram_write),
        .pin_write(pin_write),
        .flag_write(flag_write),
        .load(load),
        .halt(halt),
        .writeback_source(writeback_source),
        .alu_operation(alu_operation),
        .branch_operation(branch_operation),
        .decoded(decoded)
    );

    assign recognized = decoded[17];
    assign controls = decoded[16:0];
endmodule
