`timescale 1ns/1ps

module controller (
    input  wire clk,
    input  wire reset,
    input  wire recognized,
    input  wire is_load,
    input  wire is_halt,
    output wire fetch,
    output wire execute,
    output wire load_wait,
    output reg  halted
);
    localparam [1:0] FETCH = 2'd0;
    localparam [1:0] EXECUTE = 2'd1;
    localparam [1:0] LOAD_WAIT = 2'd2;

    reg [1:0] state;

    assign fetch = (state == FETCH);
    assign execute = (state == EXECUTE);
    assign load_wait = (state == LOAD_WAIT);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
            halted <= 1'b0;
        end else if (!halted) begin
            case (state)
                FETCH: state <= EXECUTE;
                EXECUTE: begin
                    if (is_halt)
                        halted <= 1'b1;
                    else if (is_load)
                        state <= LOAD_WAIT;
                    else if (recognized)
                        state <= FETCH;
                    else
                        halted <= 1'b1;
                end
                LOAD_WAIT: state <= FETCH;
                default: begin
                    state <= FETCH;
                    halted <= 1'b1;
                end
            endcase
        end
    end
endmodule
