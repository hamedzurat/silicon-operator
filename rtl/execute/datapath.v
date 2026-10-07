`timescale 1ns/1ps

module datapath (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] input_pins,
    input  wire [31:0] ram_read_data,
    input  wire [3:0]  rd,
    input  wire [3:0]  rs,
    input  wire [3:0]  rt,
    input  wire [11:0] immediate,
    input  wire        pc_enable,
    input  wire        pc_load,
    input  wire [7:0]  pc_load_value,
    input  wire        register_write_enable,
    input  wire [2:0]  bus_select,
    input  wire [3:0]  alu_operation,
    input  wire        output_write_enable,
    input  wire        ram_address_pc,
    input  wire        is_load,
    output wire [7:0]  ram_address,
    output wire [31:0] ram_write_data,
    output wire        alu_equal,
    output wire [15:0] output_pins
);
    wire [31:0] source_a_value;
    wire [31:0] source_b_value;
    wire [31:0] alu_result;
    wire [31:0] writeback_value;
    wire [7:0] current_pc;
    wire [7:0] indirect_address = is_load ? source_a_value[7:0] : source_b_value[7:0];
    wire [31:0] sign_extended_immediate = {{20{immediate[11]}}, immediate};
    wire [31:0] input_value = {16'b0, input_pins};

    program_counter pc(
        .clk(clk),
        .reset(reset),
        .enable(pc_enable),
        .load(pc_load),
        .load_value(pc_load_value),
        .value(current_pc)
    );

    register_file registers(
        .clk(clk),
        .reset(reset),
        .source_a_index(rs),
        .source_b_index(rt),
        .source_a_value(source_a_value),
        .source_b_value(source_b_value),
        .write_enable(register_write_enable),
        .write_address(rd),
        .write_data(writeback_value)
    );

    alu arithmetic(
        .left(source_a_value),
        .right(source_b_value),
        .operation(alu_operation),
        .result(alu_result),
        .equal(alu_equal)
    );

    address_bus memory_address_bus(
        .program_address(current_pc),
        .register_address(indirect_address),
        .select_register(!ram_address_pc),
        .address(ram_address)
    );

    data_bus writeback_bus(
        .alu_value(alu_result),
        .memory_value(ram_read_data),
        .immediate_value(sign_extended_immediate),
        .input_value(input_value),
        .register_value(source_a_value),
        .select(bus_select),
        .value(writeback_value)
    );

    assign ram_write_data = source_a_value;

    output_register pin_latch(
        .clk(clk),
        .reset(reset),
        .write_enable(output_write_enable),
        .write_data(source_a_value[15:0]),
        .value(output_pins)
    );
endmodule
