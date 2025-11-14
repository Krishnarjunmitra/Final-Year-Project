// fp_mul.v
`timescale 1ns/1ps

module fp_mul(
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);

    // Fields
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] frac_a = a[22:0];
    wire [22:0] frac_b = b[22:0];

    // Detect specials
    wire a_is_zero = (exp_a == 8'd0) && (frac_a == 23'd0);
    wire b_is_zero = (exp_b == 8'd0) && (frac_b == 23'd0);
    wire a_is_inf  = (exp_a == 8'hFF) && (frac_a == 23'd0);
    wire b_is_inf  = (exp_b == 8'hFF) && (frac_b == 23'd0);
    wire a_is_nan  = (exp_a == 8'hFF) && (frac_a != 23'd0);
    wire b_is_nan  = (exp_b == 8'hFF) && (frac_b != 23'd0);

    wire sign_r = sign_a ^ sign_b;

    wire [23:0] man_a = (exp_a == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    wire [23:0] man_b = (exp_b == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    wire [47:0] man_prod = man_a * man_b;

    wire [9:0] exp_sum = exp_a + exp_b;

    wire msb_prod = man_prod[47];
    wire [22:0] mantissa_trunc = msb_prod ? man_prod[46:24] : man_prod[45:23];

    wire [9:0] exp_unbiased_signed =
                {1'b0, exp_sum} - 10'd127 + (msb_prod ? 10'd1 : 10'd0);

    // OUTPUT REGISTERS
    reg [7:0]  exp_out;
    reg [22:0] frac_out;
    reg out_is_zero;
    reg out_is_inf;
    reg out_is_nan;

    // Declare integer OUTSIDE always
    integer exp_int;

    always @* begin
        out_is_zero = 1'b0;
        out_is_inf  = 1'b0;
        out_is_nan  = 1'b0;
        exp_out = 8'd0;
        frac_out = 23'd0;

        if (a_is_nan || b_is_nan) begin
            out_is_nan = 1'b1;
            exp_out = 8'hFF;
            frac_out = 23'h400000;

        end else if (a_is_inf || b_is_inf) begin
            if ((a_is_inf && b_is_zero) || (b_is_inf && a_is_zero)) begin
                out_is_nan = 1'b1;
                exp_out = 8'hFF;
                frac_out = 23'h400000;
            end else begin
                out_is_inf = 1'b1;
                exp_out = 8'hFF;
                frac_out = 23'd0;
            end

        end else if (a_is_zero || b_is_zero) begin
            out_is_zero = 1'b1;
            exp_out = 8'd0;
            frac_out = 23'd0;

        end else begin
            exp_int = exp_unbiased_signed;

            if (exp_int > 254) begin
                out_is_inf = 1'b1;
                exp_out = 8'hFF;
                frac_out = 23'd0;

            end else if (exp_int <= 0) begin
                out_is_zero = 1'b1;
                exp_out = 8'd0;
                frac_out = 23'd0;

            end else begin
                exp_out = exp_int[7:0];
                frac_out = mantissa_trunc;
            end
        end
    end

    assign y = out_is_nan  ? {1'b0, 8'hFF, frac_out} :
               out_is_inf  ? {sign_r, 8'hFF, 23'd0} :
               out_is_zero ? {sign_r, 8'd0, 23'd0} :
                             {sign_r, exp_out, frac_out};

endmodule
