
`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishnarjun Mitra
// 
// Create Date: 14.11.2025 13:34:36
// Design Name: fp_mul_pipelined
// Module Name: tb_fp_mul_pipelined
// 
//////////////////////////////////////////////////////////////////////////////////
// tb_fp_mul_pipelined.v

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
    always #5 clk = ~clk;   // 10ns period → 100 MHz

    // Simple procedure to apply an input and then wait.
    task apply_input;
        input [31:0] inA;
        input [31:0] inB;
        integer i;
        begin
            a = inA;
            b = inB;
            valid_in = 1'b1;
            @(posedge clk);
            valid_in = 1'b0;

            // now wait for valid_out to become 1
            for (i = 0; i < 20; i = i + 1) begin
                @(posedge clk);
                if (valid_out == 1'b1) begin
                    $display("A=0x%08h  B=0x%08h  => Y=0x%08h  (valid)", inA, inB, y);
                    disable apply_input;  // exit task properly
                end
            end
        end
    endtask

    initial begin
        $display("=== PIPELINED FP MULTIPLIER TESTBENCH START ===");

        rstn = 0;
        valid_in = 0;
        a = 32'd0;
        b = 32'd0;

        repeat(5) @(posedge clk);
        rstn = 1;

        // APPLY TEST VECTORS
        apply_input(32'h40600000, 32'hC0000000); // 3.5 * -2.0 = -7.0
        apply_input(32'h3FC00000, 32'h40000000); // 1.5 * 2.0 = 3.0
        apply_input(32'h00000000, 32'h40A00000); // 0 * 5 = 0
        apply_input(32'h7F800000, 32'h40000000); // Inf * 2 = Inf
        apply_input(32'h7FC00001, 32'h40000000); // NaN * 2 = NaN

        $display("=== TESTBENCH FINISHED ===");
        #50;
        $finish;
    end

endmodule


