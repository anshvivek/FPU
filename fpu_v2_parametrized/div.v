module division (
    input clk,rst,
    input [63:0] A,
    input [63:0] B,
    output reg [63:0] final_answer,
    output exception,
    output reg done
);
wire is_32bit = (A[63:32] == 0 && B[63:32] == 0);



parameter m_32 = 64'b0000000000000000000000000000000010111111111100001111000011110001;
parameter m_64 = 64'hBFFE1E1E1E1E1E20;
parameter n_32 = 64'b0000000000000000000000000000000001000000001101001011010010110101;
parameter n_64 = 64'h4006969696969697;
parameter two_32 = 64'b00000000000000000000000000000000001000000000000000000000000000000;
parameter two_64 = 64'h4000000000000000;


reg [63:0] m; 
reg [63:0] n; 
reg [63:0] two; 
// Internal signals and registers
reg [10:0] difference; 
reg [10:0] exponent_A;
reg [63:0] A_updated, B_updated;
wire [63:0] mul_result, add_result;
reg [63:0] xi, xi0, xi1, xi2, B_final;
reg [63:0] m_temp1,m_temp2,m_tempfinal;
reg output_sign;

// State machine variables
reg [3:0] state,nextstate;
reg [63:0] operand1, operand2, operand3, operand4;
reg add_sub_op;

// Instantiate modules
Multiplication multiplication_unit1(operand1, operand2, mul_result,,,,);
Add_Sub add_sub_unit(operand3, operand4, add_sub_op, , add_result,);



//exponent of A or B is 255
assign exception = is_32bit? ((&A[30:23]) | (&B[30:23])): ((&A[62:52]) | (&B[62:52]));

// State encoding
localparam S0 = 4'd0,
           S1 = 4'd1,
           S2 = 4'd2,
           S3 = 4'd3,
           S4 = 4'd4,
           S5 = 4'd5,
           S6 = 4'd6,
           S7 = 4'd7,
           S8 = 4'd8,
           S9 = 4'd9,
           S10 = 4'd10,
           S11 = 4'd11,
           S12 = 4'd12,
           S13 = 4'd13;
           
           
  always@(*) begin
    m = is_32bit ? m_32 : m_64;
    n = is_32bit ? n_32 : n_64;
    two = is_32bit ? two_32 : two_64;
    if (is_32bit) begin
       // Adjusting B to fit in 0.5 < B < 1
       B_updated <= {1'b0, 8'd126, B[22:0]};
       difference <= 8'd126 - B[30:23];
       exponent_A <= A[30:23] + difference;
       A_updated <= {A[31], exponent_A, A[22:0]};
       output_sign <= A[31] ^ B[31];
    end
    else begin
       B_updated <= {1'b0, 11'b01111111110, B[51:0]};
       difference <= 11'b01111111110 - B[62:52];
       exponent_A <= A[62:52] + difference;
       A_updated <= {A[63], exponent_A, A[51:0]};
       output_sign <= A[63] ^ B[63]; 
    end
  end 



// State machine for sequential operations
always @(posedge clk ) begin
        if (rst) begin
        operand1 <= 64'dx;
        operand2 <= 64'dx;
        state <= S0;
        end
        else
        state<=nextstate;
end

always @(*) begin
        done <=1'bx;
        nextstate <= state;
        case (state)
            S0: begin
                if (A !== 32'bx && B !== 32'bx && A != 32'd0 && B != 32'd0 && !exception) 
                   nextstate <= S1;              
                end             
            
            S1: begin
                // Initial guess: xi = m * B_updated
                operand1 <= m;
                operand2 <= B_updated;
                nextstate <= S2;
            end
            
            
            S2: begin
                // Add_Sub: xi0 = xi + n
                operand3 <= mul_result;
                operand4 <= n;
                add_sub_op <= 1'b0;
                xi0 <= add_result;
                nextstate <= S3;
            end
            
            S3: begin
                
                // Multiplication: m_x0 = xi0 * B_updated
                operand1 <= add_result;
                operand2 <= B_updated;
                nextstate <= S4;
            end
            
            S4: begin
                // Add_Sub: a_x0 = two - m_x0
                operand3 <= two;
                operand4 <= mul_result;
                add_sub_op <= 1'b1;
                nextstate <= S5;
            end
            
            S5: begin
                // Multiplication: xi1 = a_x0 * xi0
                operand1 <= add_result;
                operand2 <= xi0;
                nextstate <= S6;
                xi1 <= mul_result;
            end
            
            S6: begin
                
                // Multiplication: m_x1 = xi1 * B_updated
                operand1 <= xi1;
                operand2 <= B_updated;
                nextstate <= S7;
            end
            
            S7: begin
                // Add_Sub: a_x1 = two - m_x1
                operand3 <= two;
                operand4 <= mul_result;
                add_sub_op <= 1'b1;
                nextstate <= S8;
            end
            
            S8: begin
                // Multiplication: xi2 = a_x1 * xi1
                operand1 <= add_result;
                operand2 <= xi1;
                nextstate <= S9;
//                m_temp2 <= mul_result;
                xi2 <= mul_result;
            end
            
            S9: begin
                
                // Multiplication: m_x2 = xi2 * B_updated
                operand1 <= xi2;
                operand2 <= B_updated;
                nextstate <= S10;
            end
            
            S10: begin
                // Add_Sub: a_x2 = two - m_x2
                operand3 <= two;
                operand4 <= mul_result;
                add_sub_op <= 1'b1;
                nextstate <= S11;
            end
            
            S11: begin
                // Multiplication: B_final = a_x2 * xi2
                operand1 <= add_result;
                operand2 <= xi2;
                nextstate <= S12;
                B_final <= mul_result;
            end
            
            S12: begin
                
//                 Final division: result = A_updated * B_final
                operand1 <= A_updated;
                operand2 <= B_final;
                nextstate <= S13;
            end
            
            S13: begin
                final_answer <= is_32bit? {32'd0,output_sign, mul_result[30:0]}:{output_sign, mul_result[62:0]};
                nextstate <= S0; // Go back to initial nextstate
                done <= ((final_answer == final_answer)) ? 1:0;               
                
            end
            
            default: nextstate <= S1;
        endcase
end


endmodule


