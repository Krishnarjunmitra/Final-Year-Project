`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishnarjun Mitra
// Create Date: 14.11.2025
// Design Name: fp_mul_pipelined
// Module Name: tb_fp_mul_pipelined (enhanced for automated checks + vcd dumps)
//////////////////////////////////////////////////////////////////////////////////

module tb_fp_mul_pipelined();

    reg clk;
    reg rstn;
    reg valid_in;
    reg [31:0] a, b;

    wire [31:0] y;
    wire        valid_out;

    // DUT
    fp_mul_pipelined dut(
        .clk(clk),
        .rstn(rstn),
        .a(a),
        .b(b),
        .valid_in(valid_in),
        .y(y),
        .valid_out(valid_out)
    );

    // clock
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 10ns period -> 100 MHz

    // helper: check expected value
    task check_and_report;
        input [31:0] exp;
        input [8*64:1] casename;
        begin
            // compare actual y with expected exp (bitwise)
            if (y === exp) begin
                $display("PASS: %0s => expected=0x%08h got=0x%08h (time=%0t)", casename, exp, y, $time);
            end else begin
                $display("FAIL: %0s => expected=0x%08h got=0x%08h (time=%0t)", casename, exp, y, $time);
            end
        end
    endtask

    // improved apply_input: drives inputs, waits for valid_out, then returns
    task apply_input;
        input [31:0] inA;
        input [31:0] inB;
        input [31:0] expY;    // expected Y to check (use 32'hXXXXXXXX if you want skip)
        input [8*64:1] casename;
        integer i;
        begin
            a = inA;
            b = inB;
            valid_in = 1'b1;
            @(posedge clk);
            valid_in = 1'b0;

            // wait for valid_out to assert (with timeout)
            for (i = 0; i < 40; i = i + 1) begin
                @(posedge clk);
                if (valid_out == 1'b1) begin
                    $display("%0s: A=0x%08h  B=0x%08h  => Y=0x%08h (valid)  time=%0t", casename, inA, inB, y, $time);
                    if (expY !== 32'hxxxxxxxx) begin
                        // perform check
                        check_and_report(expY, casename);
                    end
                    disable apply_input;
                end
            end
            // timeout
            $display("TIMEOUT: %0s - valid_out not asserted within timeout window", casename);
        end
    endtask

    initial begin
        $display("=== PIPELINED FP MULTIPLIER TESTBENCH START ===");

        // create a single VCD covering all cases (or you can use per-case $dumpfile)
        $dumpfile("waveforms_all.vcd");
        $dumpvars(0, tb_fp_mul_pipelined);

        rstn = 0;
        valid_in = 0;
        a = 32'd0;
        b = 32'd0;

        repeat(5) @(posedge clk);
        rstn = 1;
        @(posedge clk);

        // APPLY TEST VECTORS (with expected outputs)
        // Case 1: Normal Operation (3.5 * -2.0) -> -7.0 (0xC0E00000)
        apply_input(32'h40600000, 32'hC0000000, 32'hC0E00000, "Case1_Normal");

        // Case 2: 1.5 * 2.0 = 3.0 (optional, expected 0x40400000)
        apply_input(32'h3FC00000, 32'h40000000, 32'h40400000, "Case2_1p5x2p0");

        // Case 3: Zero Handling: 0 * 5.0 -> 0.0 (0x00000000)
        apply_input(32'h00000000, 32'h40A00000, 32'h00000000, "Case3_Zero");

        // Case 4: Infinity * 2.0 -> Infinity (0x7F800000)
        apply_input(32'h7F800000, 32'h40000000, 32'h7F800000, "Case4_InfTimes2");

        // Case 5: NaN * 2.0 -> NaN (canonical quiet NaN 0x7FC00000 expected by design)
        // Note: Some designs may propagate payload; expected should match your RTL behavior.
        apply_input(32'h7FC00001, 32'h40000000, 32'h7FC00000, "Case5_NaN");

        $display("=== TESTBENCH FINISHED ===");
        #50;
        $finish;
    end

endmodule
