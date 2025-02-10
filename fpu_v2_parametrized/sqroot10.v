`timescale 1ns/1ps
module sqroot_10 (input [63:0] A,input clk,input rst, output reg [63:0] squareroot, output reg done);


parameter two_32 = 64'b00000000000000000000000000000000001000000000000000000000000000000;
parameter two_64 = 64'h4000000000000000;

reg [63:0] two; 
reg [63:0] d ;
reg [63:0] as;
reg [63:0] i ;
reg [10:0] a_expo_intialguess;
reg [63:0] initial_guess;
wire [63:0] div_result, add_result;
wire done1;
//state varibales
reg [4:0] state,nextstate;
reg [63:0] operand1,operand2,operand3,operand4;



localparam S0 = 5'd0,
           S1 = 5'd1,
           S2 = 5'd2,
           S3 = 5'd3,
           S4 = 5'd4,
           S5 = 5'd5,
           S6 = 5'd6,
           S7 = 5'd7,
           S8 = 5'd8,
           S9 = 5'd9,
           S10 = 5'd10,
           S11 = 5'd11,
           S12 = 5'd12,
           S13 = 5'd13,
           S14 = 5'd14,
           S15 = 5'd15,
           S16 = 5'd16,
           S17 = 5'd17,
           S18 = 5'd18,
           S19 = 5'd19,
           S20 = 5'd20,
           S21 = 5'd21,
           S22 = 5'd22,
           DONE =5'd23;
           
division division_unit_sq1(clk,rst,operand1,operand2,div_result,,done1);
Add_Sub add_sub_unit_sq(operand3, operand4, 1'b0, , add_result,);         
                
wire is_32bit = (A[63:32] == 0);       
           
always@(*) 
    begin
        two = is_32bit ? two_32 : two_64;
        if (is_32bit) begin
            a_expo_intialguess <= A[30:23] - 8'd1;
            initial_guess <= {A[31],a_expo_intialguess[7:0],A[22:0]};
        end    
        else begin
            a_expo_intialguess <= A[62:52] - 11'd1;
            initial_guess <= {A[63],a_expo_intialguess,A[51:0]};
        end    
    end

always @(posedge clk) 
    begin
        if (rst)
            state <= S0;
//            nextstate
        else
            state<=nextstate;
    end



always@(*) 
    begin
        done <= 1'bx;
        nextstate <= state;
        case(state)
             S0: begin
                if (A !== 32'bx && A != 32'd0) 
                nextstate <= S1;               
                end
                
             S1: begin
//                operand1 <= A;
//                operand2 <= initial_guess;
                d <= two;         
//                if (done1)
                    nextstate <= S2;           
                end
  
             
             S2: begin                
                operand3 <= d;
                operand4 <= initial_guess;
                as <= add_result;
                nextstate <= S3;
                end 
                
             S3: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S4;           
                end
  
             
             S4: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S5;
                end
                
             S5: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S6;           
                end
  
             
             S6: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S7;
                end
                
             S7: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S8;           
                end
  
             
             S8: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S9;
                end
                
             S9: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S10;           
                end
  
             
             S10: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S11;
                end
                
             S11: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S12;           
                end
  
             
             S12: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S13;
                end
                
             S13: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S14;           
                end
  
             
             S14: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S15;
                end
                
             S15: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S16;           
                end
  
             
             S16: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S17;
                end
                
             S17: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S18;           
                end
  
             
             S18: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= S19;
                end
                
             S19: begin
                operand1 <= A;
                operand2 <= i;
                d <= div_result;         
                if (done1)
                    nextstate <= S20;           
                end
  
             
             S20: begin                
                operand3 <= d;
                operand4 <= i;
                as <= add_result;
                nextstate <= DONE;
                end
                    
                
             DONE: begin
                done <= 1'b1;
                nextstate <= DONE;
                squareroot <= i;
                end
             default: nextstate <= S1;
        endcase        
    end           
 
 always@(posedge clk) 
    begin
        if (is_32bit) begin
            i <= {32'b0,add_result[31],add_result[30:23] - 8'd1,add_result[22:0]};
        end
        else begin
            i <= {add_result[63],add_result[62:52] - 11'd1,add_result[51:0]};
        end    
    end
 
  
endmodule
