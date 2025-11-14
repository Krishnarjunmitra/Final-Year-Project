
`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishnarjun Mitra
// 
// Create Date: 14.11.2025 13:34:36
// Design Name: fp_mul_pipelined
// Module Name: vedic24x24.v
// 
//////////////////////////////////////////////////////////////////////////////////
// vedic24x24.v

module vedic24x24(
    input  wire [23:0] a,
    input  wire [23:0] b,
    output wire [47:0] p
);
    // Split into hi/lo 12-bit parts
    wire [11:0] a_lo = a[11:0];
    wire [11:0] a_hi = a[23:12];
    wire [11:0] b_lo = b[11:0];
    wire [11:0] b_hi = b[23:12];

    wire [23:0] p0, p1, p2, p3;

    vedic12x12 u0(.a(a_lo), .b(b_lo), .p(p0)); // lo*lo
    vedic12x12 u1(.a(a_lo), .b(b_hi), .p(p1)); // lo*hi
    vedic12x12 u2(.a(a_hi), .b(b_lo), .p(p2)); // hi*lo
    vedic12x12 u3(.a(a_hi), .b(b_hi), .p(p3)); // hi*hi

    // Combine: p = p0 + (p1<<12) + (p2<<12) + (p3<<24)
    wire [47:0] term0 = {24'd0, p0};
    wire [47:0] term1 = {12'd0, p1, 12'b0};
    wire [47:0] term2 = {12'd0, p2, 12'b0};
    wire [47:0] term3 = {p3, 24'b0};

    assign p = term0 + term1 + term2 + term3;
endmodule
