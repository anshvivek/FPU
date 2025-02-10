`timescale 1ns/1ps
module Add_Sub(
    input [63:0] A,
    input [63:0] B,
    input add_sub_choose, //add=0,sub=1 
    output reg exception,
    output reg [63:0] result,
    output reg done
    
);

wire is_32bit = (A[63:32] == 0 && B[63:32] == 0);

reg comp_enable;
reg output_sign;
reg output_operation;
reg [63:0] A_new,B_new;
reg [52:0] MantissaAplus,MantissaBplus;
reg [10:0] exponent_difference;
reg [52:0] MantissaBplus_shifted;
//reg [7:0] exponent_B_shifted;

reg [53:0] sum;
reg [62:0] sum_result;
//reg [7:0] test;
reg [52:0] B_2scomplement;
reg [53:0] sub;
reg [62:0] sub_result;

reg [53:0] sub_diff;
reg [10:0] sub_exponent;

reg [24:0] priority_sub_32;
reg [7:0] priority_exponent_32;
wire [24:0] sub_diff_wire_32;
wire [7:0] sub_exponent_wire_32;

reg [53:0] priority_sub_64;
reg [10:0] priority_exponent_64;
wire [53:0] sub_diff_wire_64;
wire [10:0] sub_exponent_wire_64;

always@(*) begin
    if (is_32bit) begin
        // compare A B (A>B)
        {comp_enable,A_new,B_new} = (A[30:0] >= B[30:0]) ? {1'b0,{32'd0,A[31:0]},{32'd0,B[31:0]}} : {1'b1,{32'd0,B[31:0]},{32'd0,A[31:0]}};
        
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
//        test = sum_result[30:23] ;
        
        //Subtraction
        B_2scomplement = !output_operation ?  {29'd0,~MantissaBplus_shifted + 24'd1} : 24'd0;
        sub = !output_operation ? MantissaAplus + B_2scomplement[23:0] : 25'd0;
        
        priority_sub_32 = sub;
        priority_exponent_32 = A_new[30:23];
        
        // Use the output from the priority encoder
        sub_diff = sub_diff_wire_32;
        sub_exponent = sub_exponent_wire_32;
        //check 
        sub_result[30:23] = sub_exponent[7:0]; 
        sub_result[22:0] = sub_diff[22:0];
        
        //Result
        result = exception ? 64'b0 : (!output_operation ? {32'b0,output_sign,sub_result[30:0]} : {32'b0,output_sign,sum_result[30:0]});
        done = (result == result) ? 1:0;
    end
    
    else begin
        // compare A B (A>B)
        {comp_enable,A_new,B_new} = (A[62:0] >= B[62:0]) ? {1'b0,A,B} : {1'b1,B,A};
        
        output_sign = add_sub_choose ? comp_enable ? !A_new[63] : A_new[63] : A_new[63];
        output_operation = add_sub_choose ? (A_new[63]^B_new[63]) : ~(A_new[63]^B_new[63]);
        // no output if exponent of A or B >= 255
        exception = (&A_new[62:52]) | (&B_new[62:52]);
        
        //1.mantessa and 0.mantessa
        MantissaAplus = (|A_new[62:52]) ? {1'b1,A_new[51:0]} : {1'b0,A_new[51:0]};
        MantissaBplus = (|B_new[62:52]) ? {1'b1,B_new[51:0]} : {1'b0,B_new[51:0]};
        
        exponent_difference = A_new[62:52] - B_new[62:52];
        MantissaBplus_shifted = MantissaBplus >> exponent_difference;
        //exponent_B_shifted = B_new[30:23] + exponent_difference;
        
        //Addition
        sum = output_operation ? (MantissaBplus_shifted + MantissaAplus) : 54'd0;
        sum_result[51:0] = sum[53] ? (sum[0] == 1'b1) ? (sum[52:1]  /*+ 23'b1*/) : sum[52:1] : sum[51:0];
        sum_result[62:52] = sum[53] ? (sum[52:1] > 52'hfffffffffffff) ? (1'b1 + 1'b1 + A_new[62:52]) :(1'b1 + A_new[62:52]) : A_new[62:52];
        
        
        //Subtraction
        B_2scomplement = !output_operation ?  ~MantissaBplus_shifted + 53'd1 : 53'd0;
        sub = !output_operation ? MantissaAplus + B_2scomplement : 54'd0;
        
        priority_sub_64 = sub;
        priority_exponent_64 = A_new[62:52];
        
        // Use the output from the priority encoder
        sub_diff = sub_diff_wire_64;
        sub_exponent = sub_exponent_wire_64;
        sub_result[62:52] = sub_exponent;
        sub_result[51:0] = sub_diff[51:0];
        
        //Result
        result = exception ? 64'b0 : (!output_operation ? {output_sign,sub_result} : {output_sign,sum_result});
        done = (result == result) ? 1:0;
    end    
end

priority_encoder_32 p1(priority_sub_32,priority_exponent_32,sub_diff_wire_32,sub_exponent_wire_32);
priority_encoder_64 p2(priority_sub_64,priority_exponent_64,sub_diff_wire_64,sub_exponent_wire_64);


endmodule