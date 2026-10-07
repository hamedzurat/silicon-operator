`timescale 1ns/1ps

// Turns a decoded instruction into datapath, RAM, PC, and pin controls.
module control_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] ram_read_data,
    input  wire        alu_equal,
    output wire [3:0]  rd,
    output wire [3:0]  rs,
    output wire [3:0]  rt,
    output wire [11:0] immediate,
    output reg         pc_enable,
    output reg         pc_load,
    output wire [7:0]  pc_load_value,
    output reg         register_write_enable,
    output reg  [2:0]  bus_select,
    output reg  [3:0]  alu_operation,
    output reg         output_write_enable,
    output reg         ram_write_enable,
    output reg         ram_address_pc,
    output wire        is_load,
    output wire        halted
);
    wire [7:0] opcode;
    wire recognized, fetch, execute, load_wait;
    wire [15:0] controls;
    wire zero_flag;
    localparam CTRL_REGWRITE = 0;
    localparam CTRL_WB_LSB = 1;
    localparam CTRL_WB_MSB = 3;
    localparam CTRL_ALU_LSB = 4;
    localparam CTRL_ALU_MSB = 7;
    localparam CTRL_RAMWRITE = 8;
    localparam CTRL_PINWRITE = 9;
    localparam CTRL_FLAGWRITE = 10;
    localparam CTRL_LOAD = 11;
    localparam CTRL_JUMP = 12;
    localparam CTRL_BEQ = 13;
    localparam CTRL_BNE = 14;
    localparam CTRL_HALT = 15;

    wire is_halt = controls[CTRL_HALT];
    wire is_store = controls[CTRL_RAMWRITE];
    wire is_compare = controls[CTRL_FLAGWRITE];
    wire is_jump = controls[CTRL_JUMP];
    wire is_beq = controls[CTRL_BEQ];
    wire is_bne = controls[CTRL_BNE];
    wire [2:0] writeback_select = controls[CTRL_WB_MSB:CTRL_WB_LSB];
    wire [3:0] alu_select = controls[CTRL_ALU_MSB:CTRL_ALU_LSB];
    wire branch_taken = is_jump || (is_beq && zero_flag) || (is_bne && !zero_flag);

    instruction_register instruction(
        .clk(clk),
        .reset(reset),
        .load(fetch),
        .data_in(ram_read_data),
        .opcode(opcode),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .immediate(immediate)
    );

    instruction_decoder decoder(
        .opcode(opcode),
        .recognized(recognized),
        .controls(controls)
    );

    controller sequence_control(
        .clk(clk),
        .reset(reset),
        .recognized(recognized),
        .is_load(is_load),
        .is_halt(is_halt),
        .fetch(fetch),
        .execute(execute),
        .load_wait(load_wait),
        .halted(halted)
    );

    flags status(
        .clk(clk),
        .reset(reset),
        .write_zero(!reset && !halted && execute && is_compare),
        .zero_in(alu_equal),
        .zero(zero_flag)
    );

    assign is_load = controls[CTRL_LOAD];
    assign pc_load_value = immediate[7:0];

    always @* begin
        pc_enable = !halted && (fetch || (execute && branch_taken));
        pc_load = execute && branch_taken;
        ram_address_pc = fetch;
        ram_write_enable = !reset && !halted && execute && is_store;
        output_write_enable = !reset && !halted && execute && controls[CTRL_PINWRITE];

        register_write_enable = !reset && !halted && controls[CTRL_REGWRITE] && (load_wait || (execute && !is_load));
        bus_select = writeback_select;
        alu_operation = alu_select;
    end
endmodule
