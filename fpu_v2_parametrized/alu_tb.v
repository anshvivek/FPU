`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2024 04:09:07 PM
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb(

    );
     reg clk, reset;
    
    reg [2:0] opcode; // 3-bit opcode to select operation
   // input start, // signal to start operation
    reg [63:0] op_a; // Operand A
    reg [63:0] op_b; // Operand B
    wire [63:0] result; // 32-bit result
    wire exception;
    wire overflow;
    wire underflow;
    wire done; // signal to indicate operation completi
    
    alu_fsm dut (
   clk, reset, opcode, // 3-bit opcode to select operation
   // input start, // signal to start operation
    op_a, // Operand A
     op_b, // Operand B
    result, // 32-bit result
    exception,
    overflow,
    underflow, 
    done // signal to indicate operation completion
);

initial begin
clk=1;
forever #10 clk=~clk;
end

initial begin
#10 reset = 1;
#30
reset = 0;
//addition
//op_a = 64'h00000000406851EC; 
//op_b = 64'h000000004090A3D7;
//result = 32'h4102_6666
op_a = 64'h498AB51E5329001C;//1.90591045736083991748277531304E46
op_b = 64'h4988D0D7BA2C411C;  //1.77091407492357741200535094055E46  
//result add = 64'h4999C2FB06AAA09C = 3.67682453228441732948812625359E46        
  opcode = 3'b001;
  
  repeat(5)
  @(posedge clk);
  reset = 1'b1;
  @(posedge clk);
  reset = 1'b0;
           // Test Subtraction
//        op_a = 64'h0000000040C00000;
//        op_b = 64'h0000000040A00000;
        // result = 32'h3F800000
op_b = 64'h498AB51E5329001C; //1.90591045736083991748277531304E46 
op_a = 64'h4988D0D7BA2C411C; //1.77091407492357741200535094055E46
//result sub = 64'h494E44698FCBF000 = 1.3499638243726250547742437249E45
        opcode = 3'b010;
        
#40
reset=1;

 repeat(1)
 @(posedge clk);
 reset = 1'b1;
 @(posedge clk);
 reset = 1'b0; 
 //multiplication
//   op_a = 32'h000000004234851F;
//   op_b = 32'h00000000427C_851F;
        // result = 32'h4532_10E9
op_a = 64'h44C2C0127CE5E7AF; //1.77091407492357741200535094055E23
op_b= 64'h44C42DFB0B9F2A45; //1.90591045736083991748277531304E23
//result mul = 64'h4997A5F982DF4283 = 3.3752036544843440386872144736E46      
        opcode = 3'b011;

#40
reset = 1;

repeat(1)
 @(posedge clk);
 reset = 1'b1;
 @(posedge clk);
 reset = 1'b0;
 
 //Test Division
        op_a = 64'h0000000042c80000;
        op_b = 64'h0000000041880000;

        // result = 32'h40bc3c3c
        opcode = 3'b100;
        
#320
reset = 1;

repeat(1)
 @(posedge clk);
 reset = 1'b1;
 @(posedge clk);
 reset = 1'b0;
 
 // Test Square Root
//        op_a = 64'h0000000047c35000;
op_a = 64'h40F86A0000000000;
        opcode = 3'b101;


        #6000 $finish;
end
endmodule

