`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishnarjun Mitra
// Design Name: fp_mul_pipelined
// Module Name: fp_mul_pipelined
//////////////////////////////////////////////////////////////////////////////////

module fp_mul_pipelined (
    input  wire         clk,
    input  wire         rstn,   // active low reset
    input  wire [31:0]  a,
    input  wire [31:0]  b,
    input  wire         valid_in,
    output reg  [31:0]  y,
    output reg          valid_out
);

    //-------------------------------------------------------
    // Stage-0 registers (capture inputs)
    //-------------------------------------------------------
    reg [31:0] a_r, b_r;
    reg        valid_r;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            a_r <= 32'd0;
            b_r <= 32'd0;
            valid_r <= 1'b0;
        end else begin
            a_r <= a;
            b_r <= b;
            valid_r <= valid_in;
        end
    end

    //-------------------------------------------------------
    // Extract IEEE-754 fields
    //-------------------------------------------------------
    wire sign_a = a_r[31];
    wire sign_b = b_r[31];
    wire [7:0] exp_a  = a_r[30:23];
    wire [7:0] exp_b  = b_r[30:23];
    wire [22:0] frac_a = a_r[22:0];
    wire [22:0] frac_b = b_r[22:0];

    wire a_is_zero = (exp_a == 8'd0) && (frac_a == 23'd0);
    wire b_is_zero = (exp_b == 8'd0) && (frac_b == 23'd0);
    wire a_is_inf  = (exp_a == 8'hFF) && (frac_a == 23'd0);
    wire b_is_inf  = (exp_b == 8'hFF) && (frac_b == 23'd0);
    wire a_is_nan  = (exp_a == 8'hFF) && (frac_a != 23'd0);
    wire b_is_nan  = (exp_b == 8'hFF) && (frac_b != 23'd0);

    wire sign_r = sign_a ^ sign_b;

    //-------------------------------------------------------
    // Prepare normalized mantissas (24 bits)
    //-------------------------------------------------------
    wire [23:0] man_a = (exp_a == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    wire [23:0] man_b = (exp_b == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    //-------------------------------------------------------
    // Stage-1: Vedic 24×24 mantissa multiply
    //-------------------------------------------------------
    wire [47:0] man_prod;
    vedic24x24 vedic_u(.a(man_a), .b(man_b), .p(man_prod));

    // exponent raw sum
    wire [9:0] exp_sum = exp_a + exp_b;

    // normalization decision
    wire msb_prod = man_prod[47];

    // normalized mantissa (no rounding)
    wire [22:0] mant_trunc =
        msb_prod ? man_prod[46:24] : man_prod[45:23];

    // exponent after bias removal and norm adjust
    wire [9:0] exp_unbiased_signed =
        {1'b0, exp_sum} - 10'd127 + (msb_prod ? 10'd1 : 10'd0);

    //-------------------------------------------------------
    // Stage-1 pipeline registers
    //-------------------------------------------------------
    reg [22:0] mant_r;
    reg [9:0]  expu_r;
    reg        a_zero_r, b_zero_r;
    reg        a_inf_r, b_inf_r;
    reg        a_nan_r, b_nan_r;
    reg        sign_r_r;
    reg        valid_stage1;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mant_r <= 23'd0;
            expu_r <= 10'd0;
            a_zero_r <= 1'b0; b_zero_r <= 1'b0;
            a_inf_r <= 1'b0;  b_inf_r <= 1'b0;
            a_nan_r <= 1'b0;  b_nan_r <= 1'b0;
            sign_r_r <= 1'b0;
            valid_stage1 <= 1'b0;
        end else begin
            mant_r <= mant_trunc;
            expu_r <= exp_unbiased_signed;
            a_zero_r <= a_is_zero;
            b_zero_r <= b_is_zero;
            a_inf_r  <= a_is_inf;
            b_inf_r  <= b_is_inf;
            a_nan_r  <= a_is_nan;
            b_nan_r  <= b_is_nan;
            sign_r_r <= sign_r;
            valid_stage1 <= valid_r;
        end
    end

    //-------------------------------------------------------
    // Stage-2: finalize result (NO DECLARATIONS ALLOWED HERE)
    //-------------------------------------------------------
    reg [31:0] y_next;
    reg        valid_next;

    // declare signed exponent interpreter OUTSIDE the always block
    reg signed [15:0] exp_s;

    always @* begin
        y_next     = 32'd0;
        valid_next = 1'b0;

        if (!valid_stage1) begin
            y_next     = 32'd0;
            valid_next = 1'b0;
        end

        // NaN cases
        else if (a_nan_r || b_nan_r) begin
            valid_next = 1'b1;
            y_next = {1'b0, 8'hFF, 23'h400000}; // quiet NaN
        end

        // Inf cases
        else if (a_inf_r || b_inf_r) begin
            if ((a_inf_r && b_zero_r) || (b_inf_r && a_zero_r)) begin
                valid_next = 1'b1;
                y_next = {1'b0, 8'hFF, 23'h400000}; // NaN
            end else begin
                valid_next = 1'b1;
                y_next = {sign_r_r, 8'hFF, 23'd0};  // Inf
            end
        end

        // Zero cases
        else if (a_zero_r || b_zero_r) begin
            valid_next = 1'b1;
            y_next = {sign_r_r, 8'd0, 23'd0};
        end

        // Normal case
        else begin
            exp_s = $signed(expu_r);  // interpret exponent as signed

            if (exp_s > 254) begin
                // overflow → Inf
                valid_next = 1'b1;
                y_next = {sign_r_r, 8'hFF, 23'd0};
            end
            else if (exp_s <= 0) begin
                // underflow → zero
                valid_next = 1'b1;
                y_next = {sign_r_r, 8'd0, 23'd0};
            end
            else begin
                valid_next = 1'b1;
                y_next = {sign_r_r, exp_s[7:0], mant_r};
            end
        end
    end

    //-------------------------------------------------------
    // Output register
    //-------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            y <= 32'd0;
            valid_out <= 1'b0;
        end else begin
            y <= y_next;
            valid_out <= valid_next;
        end
    end

endmodule
