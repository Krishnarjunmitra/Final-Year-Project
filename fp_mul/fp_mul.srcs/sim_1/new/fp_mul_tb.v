// fp_mul_tb.v
`timescale 1ns/1ps
module fp_mul_tb();

    reg [31:0] a, b;
    wire [31:0] y;

    fp_mul uut (.a(a), .b(b), .y(y));

    // helper task to print hex/fields
    task print_vec;
        input [31:0] v;
        begin
            $display("0x%08h  sign=%0b exp=%0d frac=0x%06h", v, v[31], v[30:23], v[22:0]);
        end
    endtask

    initial begin
        $display("Starting testbench...");

        // Test 1: 3.5 * -2.0 = -7.0
        // 3.5 = 0x40600000 ; -2.0 = 0xC0000000 ; -7.0 = 0xC0E00000
        a = 32'h40600000; b = 32'hC0000000;
        #5;
        $display("\nTest1: 3.5 * -2.0");
        print_vec(a); print_vec(b); print_vec(y);
        $display("Result hex = 0x%08h (expected approx 0xC0E00000)", y);

        // Test 2: 1.5 * 2.0 = 3.0
        // 1.5 = 0x3FC00000 ; 2.0 = 0x40000000 ; 3.0 = 0x40400000
        a = 32'h3FC00000; b = 32'h40000000;
        #5;
        $display("\nTest2: 1.5 * 2.0");
        print_vec(a); print_vec(b); print_vec(y);
        $display("Result hex = 0x%08h (expected approx 0x40400000)", y);

        // Test 3: 0.0 * 5.0 = 0.0
        a = 32'h00000000; b = 32'h40A00000; // 5.0 = 0x40A00000
        #5;
        $display("\nTest3: 0.0 * 5.0");
        print_vec(a); print_vec(b); print_vec(y);

        // Test 4: Inf * 2.0 -> Inf
        a = 32'h7F800000; b = 32'h40000000;
        #5;
        $display("\nTest4: Inf * 2.0");
        print_vec(a); print_vec(b); print_vec(y);

        // Test 5: NaN propagation
        a = 32'h7FC00001; b = 32'h40000000;
        #5;
        $display("\nTest5: NaN * 2.0");
        print_vec(a); print_vec(b); print_vec(y);

        $display("\nTests completed.");
        $finish;
    end
endmodule
