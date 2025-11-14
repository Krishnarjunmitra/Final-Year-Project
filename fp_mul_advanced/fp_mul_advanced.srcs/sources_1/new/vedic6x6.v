
`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishnarjun Mitra
// 
// Create Date: 14.11.2025 13:34:36
// Design Name: fp_mul_pipelined
// Module Name: vedic6x6.v
// 
//////////////////////////////////////////////////////////////////////////////////
// vedic6x6.v
module vedic6x6(
    input  wire [5:0] a,
    input  wire [5:0] b,
    output wire [11:0] p
);
    // Split into hi and lo 3-bit parts
    wire [2:0] a_lo = a[2:0];
    wire [2:0] a_hi = a[5:3];
    wire [2:0] b_lo = b[2:0];
    wire [2:0] b_hi = b[5:3];

    wire [5:0] p0;
    wire [5:0] p1;
    wire [5:0] p2;
    wire [5:0] p3;

    vedic3x3 u0(.a(a_lo), .b(b_lo), .p(p0));   // low*low
    vedic3x3 u1(.a(a_lo), .b(b_hi), .p(p1));   // low*hi
    vedic3x3 u2(.a(a_hi), .b(b_lo), .p(p2));   // hi*low
    vedic3x3 u3(.a(a_hi), .b(b_hi), .p(p3));   // hi*hi

    // Combine: product = p0 + (p1<<3) + (p2<<3) + (p3<<6)
    wire [11:0] term0 = {6'd0, p0}; // aligns bits [5:0]
    wire [11:0] term1 = {3'd0, p1, 3'b000}; // shift left by 3
    wire [11:0] term2 = {3'd0, p2, 3'b000};
    wire [11:0] term3 = {p3, 6'b000000}; // shift left by 6

    assign p = term0 + term1 + term2 + term3;
endmodule
