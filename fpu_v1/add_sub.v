`timescale 1ns/1ps
module Add_Sub(
    input [31:0] A,
    input [31:0] B,
    input add_sub_choose, //add=0,sub=1 
    output reg exception,
    output reg [31:0] result,
    output reg done
    
);

reg comp_enable;
reg output_sign;
reg output_operation;
reg [31:0] A_new,B_new;
reg [23:0] MantissaAplus,MantissaBplus;
reg [7:0] exponent_difference;
reg [23:0] MantissaBplus_shifted;
//reg [7:0] exponent_B_shifted;

reg [24:0] sum;
reg [30:0] sum_result;

reg [23:0] B_2scomplement;
reg [24:0] sub;
reg [30:0] sub_result;

reg [24:0] sub_diff;
reg [7:0] sub_exponent;

reg [24:0] priority_sub;
reg [7:0] priority_exponent;
wire [24:0] sub_diff_wire;
wire [7:0] sub_exponent_wire;

always@(*) begin

// compare A B (A>B)
{comp_enable,A_new,B_new} = (A[30:0] >= B[30:0]) ? {1'b0,A,B} : {1'b1,B,A};

output_sign = add_sub_choose ? comp_enable ? !A_new[31] : A_new[31] : A_new[31];
output_operation = add_sub_choose ? (A_new[31]^B_new[31]) : ~(A_new[31]^B_new[31]);
// no output if exponent of A or B >= 255
exception = (&A_new[30:23]) | (&B_new[30:23]);

//1.mantessa and 0.mantessa
MantissaAplus = (|A_new[30:23]) ? {1'b1,A_new[22:0]} : {1'b0,A_new[22:0]};
MantissaBplus = (|B_new[30:23]) ? {1'b1,B_new[22:0]} : {1'b0,B_new[22:0]};

exponent_difference = A_new[30:23] - B_new[30:23];
MantissaBplus_shifted = MantissaBplus >> exponent_difference;
//exponent_B_shifted = B_new[30:23] + exponent_difference;

//Addition
sum = output_operation ? (MantissaBplus_shifted + MantissaAplus) : 25'd0;
sum_result[22:0] = sum[24] ? (sum[0] == 1'b1) ? (sum[23:1]  /*+ 23'b1*/) : sum[23:1] : sum[22:0];
sum_result[30:23] = sum[24] ? (sum[23:1] > 23'h7fffff) ? (1'b1 + 1'b1 + A_new[30:23]) :(1'b1 + A_new[30:23]) : A_new[30:23];


//Subtraction
B_2scomplement = !output_operation ?  ~MantissaBplus_shifted + 24'd1 : 24'd0;
sub = !output_operation ? MantissaAplus + B_2scomplement : 25'd0;

priority_sub = sub;
priority_exponent = A_new[30:23];

// Use the output from the priority encoder
sub_diff = sub_diff_wire;
sub_exponent = sub_exponent_wire;
sub_result[30:23] = sub_exponent;
sub_result[22:0] = sub_diff[22:0];

//Result
result = exception ? 32'b0 : (!output_operation ? {output_sign,sub_result} : {output_sign,sum_result});
done = (result == result) ? 1:0;
//if (exponent_255)
end

priority_encoder p1(priority_sub,priority_exponent,sub_diff_wire,sub_exponent_wire);

endmodule

