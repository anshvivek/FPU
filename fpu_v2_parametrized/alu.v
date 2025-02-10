`timescale 1ns/1ps
module alu_fsm(
    input clk,
    input reset,
    input [2:0] opcode, // 3-bit opcode to select operation
    input [63:0] op_a, // Operand A
    input [63:0] op_b, // Operand B
    output reg [63:0] result, // 32-bit result
    output reg exception,
    output reg overflow,
    output reg underflow,
    output reg done // signal to indicate operation completion
);

// State encoding using parameters
//parameter IDLE = 3'b000;
parameter ADD = 3'b001;
parameter SUB = 3'b010;
parameter MUL = 3'b011;
parameter DIV = 3'b100;
parameter SQRT = 3'b101;
parameter DONE = 3'b110;


// Intermediate outputs from operation modules
wire [63:0] add_output;
wire [63:0] sub_output;
wire [63:0] mul_output;
wire [63:0] div_output;
wire [63:0] sqrt_output;
wire done_sig_sq,done_sig_add,done_sig_sub,done_sig_mul,done_sig_div;
wire exception_add,exception_sub,exception_mul,exception_div;
wire overflow_mul,underflow_mul;

// Instantiate operation modules
Add_Sub A_ALU(op_a, op_b, 1'b0,exception_add, add_output,done_sig_add);
Add_Sub S_ALU(op_a, op_b, 1'b1,exception_sub, sub_output,done_sig_sub);
Multiplication M_ALU(op_a, op_b, mul_output,exception_mul,overflow_mul,underflow_mul,done_sig_mul);
division D_ALU(clk,reset,op_a, op_b, div_output,exception_div,done_sig_div);
sqroot_10 sq_ALU(op_a,clk,reset, sqrt_output,done_sig_sq);



// Output logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 32'bx;
        done <= 1'b0;
        exception <= 1'b0;
        overflow <= 1'b0;
        underflow <= 1'b0;
    end 
    else begin        
        case (opcode)
            ADD: begin result <= add_output; done <= done_sig_add; exception <= exception_add; end
            SUB: begin result <= sub_output; done <= done_sig_sub; exception <= exception_sub; end
            MUL: begin result <= mul_output; done <= done_sig_mul; exception <= exception_mul; overflow <= overflow_mul; underflow <= underflow_mul; end
            DIV: begin result <= div_output; done <= done_sig_div; exception <= exception_div; end
            SQRT: begin result <= sqrt_output; done <= done_sig_sq; end      
            default: done <= 1'b0;
        endcase
     end
end

endmodule

