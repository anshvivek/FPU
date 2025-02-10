`timescale 1ns/1ps
module Multiplication(
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] result,
    output reg exception,
    output reg overflow,
    output reg underflow,
    output reg done
);

reg output_sign;
reg [23:0] MantissaAplus;
reg [23:0] MantissaBplus;
reg [8:0] expo_add;
reg [8:0] product_exponent;
reg [47:0] product;
reg [46:0] normalized_product;
reg [8:0] product_exponent_updated;
reg [23:0] product_mantissa;
//wire [22:0] product_mantissa_updated;
reg [8:0] product_exponent_afterroundoff;
reg roundoff;
reg zero;
//reg exception;
//reg overflow;
//reg underflow;


always@(A,B) begin
output_sign = A[31]^B[31];

//if exponent is 255
exception = (A[30:23] == 8'd255) | (B[30:23] == 8'd255) ; 
zero = (A[30:23] == 8'b0) & (A[22:0] == 23'b0) | (B[30:23] == 8'b0);


MantissaAplus = (|A[30:23]) ? {1'b1,A[22:0]} : {1'b0,A[22:0]};
MantissaBplus = (|B[30:23]) ? {1'b1,B[22:0]} : {1'b0,B[22:0]};

expo_add = A[30:23] + B[30:23];
product_exponent = expo_add - 8'd127;

product = MantissaAplus * MantissaBplus;
normalized_product = product[47] ? product >> 1 : product;
product_exponent_updated = product[47] ? product_exponent + 1'b1 : product_exponent;
// implement rounding off (if normalised_product has [45:23] as all 1's then this would not work)
roundoff = (|normalized_product[21:0]);
product_mantissa = normalized_product[45:23] + (roundoff & normalized_product[22]);
product_exponent_afterroundoff = product_mantissa[23] ? product_exponent_updated + 1'b1 : product_exponent_updated;

overflow = (product_exponent_afterroundoff[7:0] > 8'd254);
underflow = product_exponent_afterroundoff[7:0] == 8'b0;
result = exception ? 32'b0  : zero ? {output_sign,31'b0} : overflow ? {output_sign,8'hFE,23'h7FFFFF}: underflow ? {output_sign,31'b0} :{output_sign,product_exponent_afterroundoff[7:0],product_mantissa[22:0]};
done = (result == result) ? 1:0;
end

endmodule

