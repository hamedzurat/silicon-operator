`timescale 1ns/1ps

module microprocessor #(
    parameter PROGRAM_FILE = ""
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] input_pins,
    output wire [15:0] output_pins,
    output wire        halted
);
    wire [31:0] ram_read_data;
    wire [31:0] data_read_data;
    wire [31:0] program_read_data;
    wire [31:0] ram_write_data;
    wire [7:0] ram_address;
    wire ram_write_enable;
    wire [3:0] rd, rs, rt;
    wire [11:0] immediate;
    wire pc_enable, pc_load, register_write_enable;
    wire [7:0] pc_load_value;
    wire [2:0] bus_select;
    wire [3:0] alu_operation;
    wire output_write_enable, ram_address_pc, is_load, alu_equal;

    control_unit control(
        .clk(clk),
        .reset(reset),
        .ram_read_data(ram_read_data),
        .alu_equal(alu_equal),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .immediate(immediate),
        .pc_enable(pc_enable),
        .pc_load(pc_load),
        .pc_load_value(pc_load_value),
        .register_write_enable(register_write_enable),
        .bus_select(bus_select),
        .alu_operation(alu_operation),
        .output_write_enable(output_write_enable),
        .ram_write_enable(ram_write_enable),
        .ram_address_pc(ram_address_pc),
        .is_load(is_load),
        .halted(halted)
    );

    rom #(.INIT_FILE(PROGRAM_FILE)) program_rom(
        .address(ram_address),
        .read_data(program_read_data)
    );

    assign ram_read_data = ram_address_pc ? program_read_data : data_read_data;

    datapath data(
        .clk(clk),
        .reset(reset),
        .input_pins(input_pins),
        .ram_read_data(ram_read_data),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .immediate(immediate),
        .pc_enable(pc_enable),
        .pc_load(pc_load),
        .pc_load_value(pc_load_value),
        .register_write_enable(register_write_enable),
        .bus_select(bus_select),
        .alu_operation(alu_operation),
        .output_write_enable(output_write_enable),
        .ram_address_pc(ram_address_pc),
        .is_load(is_load),
        .ram_address(ram_address),
        .ram_write_data(ram_write_data),
        .alu_equal(alu_equal),
        .output_pins(output_pins)
    );

    ram data_memory(
        .clk(clk),
        .address(ram_address),
        .write_data(ram_write_data),
        .write_enable(ram_write_enable),
        .read_data(data_read_data)
    );
endmodule
