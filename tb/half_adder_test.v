`timescale 1ns/1ps

module half_adder_test;

reg a;
reg b;
wire sum;
wire carry;
integer tests;

half_adder dut (
    .a(a),
    .b(b),
    .sum(sum),
    .carry(carry)
);

task check;
    input test_a;
    input test_b;
    input expected_sum;
    input expected_carry;
    begin
        a = test_a;
        b = test_b;
        #1;
        assert ({carry, sum} === {expected_carry, expected_sum})
        else begin
            $display("FAIL a=%b b=%b got={%b,%b} expected={%b,%b}",
                     test_a, test_b, carry, sum, expected_carry, expected_sum);
            $fatal(1, "half_adder mismatch");
        end
        tests = tests + 1;
    end
endtask

initial begin
    tests = 0;
    $dumpfile("build/half_adder.vcd");
    $dumpvars(0, half_adder_test);
    check(1'b0, 1'b0, 1'b0, 1'b0);
    check(1'b0, 1'b1, 1'b1, 1'b0);
    check(1'b1, 1'b0, 1'b1, 1'b0);
    check(1'b1, 1'b1, 1'b0, 1'b1);
    $display("PASS: %0d half_adder tests", tests);
    $finish;
end

endmodule
