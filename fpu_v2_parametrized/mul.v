`timescale 1ns/1ps
module Multiplication(
    input [63:0] A,
    input [63:0] B,
    output reg [63:0] result,
    output reg exception,
    output reg overflow,
    output reg underflow,
    output reg done
);

reg output_sign;
reg [52:0] MantissaAplus;
reg [52:0] MantissaBplus;
reg [11:0] expo_add;
reg [11:0] product_exponent;
reg [105:0] product;
reg [104:0] normalized_product;
reg [11:0] product_exponent_updated;
reg [52:0] product_mantissa;
//wire [22:0] product_mantissa_updated;
reg [11:0] product_exponent_afterroundoff;
reg roundoff;
reg zero;
//reg exception;
//reg overflow;
//reg underflow;

wire is_32bit = (A[63:32] == 0 && B[63:32] == 0);

always@(A,B) begin
    if (is_32bit) begin
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
    
    else begin
        output_sign = A[63]^B[63];
        
        //if exponent is 255
        exception = (A[62:52] == 11'b11111111111) | (B[62:52] == 11'b11111111111) ; 
        zero = (A[62:52] == 11'b0) & (A[51:0] == 52'b0) | (B[62:52] == 11'b0);
        
        
        MantissaAplus = (|A[62:52]) ? {1'b1,A[51:0]} : {1'b0,A[51:0]};
        MantissaBplus = (|B[62:52]) ? {1'b1,B[51:0]} : {1'b0,B[51:0]};
        
        expo_add = A[62:52] + B[62:52];
        product_exponent = expo_add - 11'b01111111111;
        
        product = MantissaAplus * MantissaBplus;
        normalized_product = product[105] ? product >> 1 : product;
        product_exponent_updated = product[105] ? product_exponent + 1'b1 : product_exponent;
        // implement rounding off (if normalised_product has [45:23] as all 1's then this would not work)
        roundoff = (|normalized_product[50:0]);
        product_mantissa = normalized_product[103:52] + (roundoff & normalized_product[51]);
        product_exponent_afterroundoff = product_mantissa[52] ? product_exponent_updated + 1'b1 : product_exponent_updated;
        
        overflow = (product_exponent_afterroundoff[10:0] > 11'b11111111110);
        underflow = product_exponent_afterroundoff[10:0] == 11'b0;
        result = exception ? 64'b0  : zero ? {output_sign,63'b0} : overflow ? {output_sign,11'b11111111110,52'hfffffffffffff}: underflow ? {output_sign,63'b0} :{output_sign,product_exponent_afterroundoff[10:0],product_mantissa[51:0]};
        done = (result == result) ? 1:0;
    end    
end

endmodule

