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
    wire [16:0] controls;
    wire zero_flag;
    localparam CTRL_HALT = 16;
    localparam CTRL_LOAD = 15;
    localparam CTRL_FLAGWRITE = 14;
    localparam CTRL_PINWRITE = 13;
    localparam CTRL_RAMWRITE = 12;
    localparam CTRL_REGWRITE = 11;
    localparam CTRL_BRANCH_MSB = 10;
    localparam CTRL_BRANCH_LSB = 7;
    localparam CTRL_ALU_MSB = 6;
    localparam CTRL_ALU_LSB = 3;
    localparam CTRL_WB_MSB = 2;
    localparam CTRL_WB_LSB = 0;

    wire is_halt = controls[CTRL_HALT];
    wire is_load_control = controls[CTRL_LOAD];
    wire is_compare = controls[CTRL_FLAGWRITE];
    wire is_output = controls[CTRL_PINWRITE];
    wire is_store = controls[CTRL_RAMWRITE];
    wire register_write = controls[CTRL_REGWRITE];
    wire [3:0] branch_operation = controls[CTRL_BRANCH_MSB:CTRL_BRANCH_LSB];
    wire [3:0] alu_select = controls[CTRL_ALU_MSB:CTRL_ALU_LSB];
    wire [2:0] writeback_select = controls[CTRL_WB_MSB:CTRL_WB_LSB];
    wire branch_taken;

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

    branch_unit branch_control(
        .operation(branch_operation),
        .zero_flag(zero_flag),
        .taken(branch_taken)
    );

    assign is_load = is_load_control;
    assign pc_load_value = immediate[7:0];

    always @* begin
        pc_enable = !halted && (fetch || (execute && branch_taken));
        pc_load = execute && branch_taken;
        ram_address_pc = fetch;
        ram_write_enable = !reset && !halted && execute && is_store;
        output_write_enable = !reset && !halted && execute && is_output;

        register_write_enable = !reset && !halted && register_write && (load_wait || (execute && !is_load));
        bus_select = writeback_select;
        alu_operation = alu_select;
    end
endmodule
