
`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishnarjun Mitra
// 
// Create Date: 14.11.2025 13:34:36
// Design Name: fp_mul_pipelined
// Module Name: vedic12x12.v
// 
//////////////////////////////////////////////////////////////////////////////////
// vedic12x12.v
module vedic12x12(
    input  wire [11:0] a,
    input  wire [11:0] b,
    output wire [23:0] p
);
    // Split into hi/lo 6-bit parts
    wire [5:0] a_lo = a[5:0];
    wire [5:0] a_hi = a[11:6];
    wire [5:0] b_lo = b[5:0];
    wire [5:0] b_hi = b[11:6];

    wire [11:0] p0, p1, p2, p3;

    vedic6x6 u0(.a(a_lo), .b(b_lo), .p(p0)); // lo*lo
    vedic6x6 u1(.a(a_lo), .b(b_hi), .p(p1)); // lo*hi
    vedic6x6 u2(.a(a_hi), .b(b_lo), .p(p2)); // hi*lo
    vedic6x6 u3(.a(a_hi), .b(b_hi), .p(p3)); // hi*hi

    // Combine: p = p0 + (p1<<6) + (p2<<6) + (p3<<12)
    wire [23:0] term0 = {12'd0, p0};
    wire [23:0] term1 = {6'd0, p1, 6'b0};
    wire [23:0] term2 = {6'd0, p2, 6'b0};
    wire [23:0] term3 = {p3, 12'b0};

    assign p = term0 + term1 + term2 + term3;
endmodule
