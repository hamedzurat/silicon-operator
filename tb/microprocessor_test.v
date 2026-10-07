`timescale 1ns/1ps

module microprocessor_test;
    reg clk;
    reg reset;
    reg [15:0] input_pins;
    wire [15:0] output_pins;
    wire halted;
    integer cycles;
    reg [31:0] alu_left;
    reg [31:0] alu_right;
    reg [3:0] alu_operation;
    wire [31:0] alu_result;
    wire alu_equal;

    microprocessor #(.PROGRAM_FILE("tb/program.hex")) dut(
        .clk(clk), .reset(reset), .input_pins(input_pins),
        .output_pins(output_pins), .halted(halted)
    );

    alu alu_under_test(
        .left(alu_left), .right(alu_right), .operation(alu_operation),
        .result(alu_result), .equal(alu_equal)
    );

    function [31:0] instruction;
        input [7:0] opcode;
        input [3:0] destination;
        input [3:0] source_a;
        input [3:0] source_b;
        input [11:0] immediate;
        begin
            instruction = {opcode, destination, source_a, source_b, immediate};
        end
    endfunction

    task wait_for_output;
        input [15:0] expected;
        begin
            cycles = 0;
            while (output_pins !== expected && cycles < 100) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
            end
            assert (output_pins === expected) else begin
                $display("FAIL output got=%h expected=%h halted=%b", output_pins, expected, halted);
                $fatal(1, "output timeout");
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        input_pins = 16'h5ac3;

        // Exercise all four ALU operation selections, including the ALU's
        // standalone equality and inequality results.
        alu_left = 32'd9;
        alu_right = 32'd4;
        alu_operation = 4'd0;
        #1;
        assert (alu_result === 32'd13) else $fatal(1, "ALU ADD failed");
        alu_operation = 4'd1;
        #1;
        assert (alu_result === 32'd5) else $fatal(1, "ALU SUB failed");
        alu_operation = 4'd2;
        #1;
        assert (alu_result === 32'd0 && alu_equal === 1'b0)
            else $fatal(1, "ALU equality compare failed for unequal inputs");
        alu_operation = 4'd3;
        #1;
        assert (alu_result === 32'd1) else $fatal(1, "ALU inequality compare failed");
        alu_left = 32'd4;
        alu_right = 32'd4;
        alu_operation = 4'd2;
        #1;
        assert (alu_result === 32'd1 && alu_equal === 1'b1)
            else $fatal(1, "ALU equality compare failed for equal inputs");
        alu_left = 32'hffffffff;
        alu_right = 32'd1;
        alu_operation = 4'd0;
        #1;
        assert (alu_result === 32'b0) else $fatal(1, "ALU 32-bit addition wrap failed");
        alu_left = 32'b0;
        alu_right = 32'd1;
        alu_operation = 4'd1;
        #1;
        assert (alu_result === 32'hffffffff)
            else $fatal(1, "ALU 32-bit subtraction wrap failed");
        alu_operation = 4'hf;
        #1;
        assert (alu_result === 32'b0)
            else $fatal(1, "unsupported ALU operation did not return zero");

        // The ROM image runs every opcode, both outcomes of each conditional
        // branch, a jump, RAM load/store, and input/output.
        assert (dut.program_rom.mem[0] === 32'h00000000 &&
                dut.program_rom.mem[25] === 32'h07098000 &&
                dut.program_rom.mem[33] === 32'h0d000000)
            else $fatal(1, "ROM program image did not load correctly");

        $dumpfile("build/microprocessor.vcd");
        $dumpvars(0, microprocessor_test);

        repeat (2) @(posedge clk);
        #1 reset = 1'b0;

        wait_for_output(16'd20);
        wait_for_output(16'd13);
        wait_for_output(16'd14);
        wait_for_output(16'd10);
        wait_for_output(16'h0321);
        assert (dut.data_memory.mem[200] === 32'h00000321)
            else $fatal(1, "STORE did not update data RAM");
        assert (dut.program_rom.mem[25] === instruction(8'h07, 4'd0, 4'd9, 4'd8, 12'd0))
            else $fatal(1, "data store modified the instruction ROM");
        wait_for_output(input_pins);
        wait_for_output(16'd6);

        cycles = 0;
        while (!halted && cycles < 20) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end
        assert (halted) else $fatal(1, "CPU did not halt");

        // Exercise reset and verify the register file was cleared: r1 was 20
        // in the first run, so OUT r1 must now produce zero.
        reset = 1'b1;
        dut.program_rom.mem[0] = instruction(8'h0c, 4'd0, 4'd1, 4'd0, 12'd0); // OUT r1
        dut.program_rom.mem[1] = instruction(8'h0d, 4'd0, 4'd0, 4'd0, 12'd0); // HALT
        repeat (2) @(posedge clk);
        #1;
        assert (output_pins === 16'b0 && halted === 1'b0)
            else $fatal(1, "reset did not clear output/halt state");
        reset = 1'b0;
        cycles = 0;
        while (!halted && cycles < 10) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end
        assert (halted && output_pins === 16'b0)
            else $fatal(1, "reset did not clear the general-purpose registers");

        // Reserved opcode behavior is deliberately deterministic.
        reset = 1'b1;
        dut.program_rom.mem[0] = instruction(8'hff, 4'd0, 4'd0, 4'd0, 12'd0);
        repeat (2) @(posedge clk);
        #1 reset = 1'b0;
        cycles = 0;
        while (!halted && cycles < 10) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end
        assert (halted) else $fatal(1, "reserved opcode did not halt");

        $display("PASS: all implemented opcodes, branch paths, RAM, I/O, reset, and reserved opcode");
        $finish;
    end
endmodule
