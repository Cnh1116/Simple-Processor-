// File Name: Matrix_ALU.sv
//
// Name: Carson Holland
//
// Date: April 27th, 2023
// 
// File Purpose: Accepts 2 operands and performs various Matrix related operations on them. Operations and their opcodes
// are listed in the module below
// 
// Assistance / Credit: 

module MatrixAlu(Clk,MatrixDataOut,ExeDataOut, address, nRead,nWrite, nReset);

input logic Clk, nReset, nWrite,nRead; //Inputs
input logic [15:0] address;
input logic [255:0] ExeDataOut;

output logic [255:0] MatrixDataOut; //Output

logic [15:0] source_1_matrix [3:0][3:0];
logic [15:0] source_2_matrix [3:0][3:0];
logic [15:0] result_matrix [3:0][3:0];
logic [7:0] operation;

//MATRIX ALU REGISTER ADDRESSES
logic [255:0] matrixALU_registers[5];
parameter source_1 = 0;
parameter source_2 = 1;
parameter result = 2;
parameter status_in = 3;
parameter status_out = 4;

assign operation = matrixALU_registers[status_in];

parameter Mmult1 = 8'h00; //4x4 times 4x4
parameter Mmult2 = 8'h01; //4x2 times 2x4
parameter Mmult3 = 8'h02; //2x4 times 4x2
parameter Madd = 8'h03; //4x4 + 4x4
parameter Msub = 8'h04; //4x4 - 4x4
parameter Mtranspose = 8'h05; //Rows & Collumns swap
parameter Mscale = 8'h06; //4x4 time a
parameter MscaleIMM = 8'h07; //4x4 times immediate
always_comb begin
    
    if(~nReset) begin
            matrixALU_registers[source_1] = 256'h0;
            matrixALU_registers[source_2] = 256'h0;
            matrixALU_registers[result] = 256'h0;
            matrixALU_registers[status_in] = 256'h0;
            matrixALU_registers[status_out] = 256'h0;
            result_matrix[0] = '{16'h0,16'h0,16'h0,16'h0};
            result_matrix[1] = '{16'h0,16'h0,16'h0,16'h0};
            result_matrix[2] = '{16'h0,16'h0,16'h0,16'h0};
            result_matrix[3] = '{16'h0,16'h0,16'h0,16'h0};
    end
    
    if(address[15:12] == MatrixAluEn) begin
    
        if(~nRead) begin
            MatrixDataOut = matrixALU_registers[address[11:0]];
        end
        if(nWrite == 0) begin
        
            matrixALU_registers[status_out] = 256'h0; //IF I am writing new data, result is not accurate yet
            matrixALU_registers[address[11:0]] = ExeDataOut;
            if (address[11:0] == 0) begin //If writing to source 1, parse the word into the matrix
                source_1_matrix[0][0] = ExeDataOut[15:0];
                source_1_matrix[0][1] = ExeDataOut[31:16];
                source_1_matrix[0][2] = ExeDataOut[47:32];
                source_1_matrix[0][3] = ExeDataOut[63:48];
                
                source_1_matrix[1][0] = ExeDataOut[79:64];
                source_1_matrix[1][1] = ExeDataOut[95:80];
                source_1_matrix[1][2] = ExeDataOut[111:96];
                source_1_matrix[1][3] = ExeDataOut[127:112];
                
                source_1_matrix[2][0] = ExeDataOut[143:128];
                source_1_matrix[2][1] = ExeDataOut[159:144];
                source_1_matrix[2][2] = ExeDataOut[175:160];
                source_1_matrix[2][3] = ExeDataOut[191:176]; 
                
                source_1_matrix[3][0] = ExeDataOut[207:192];
                source_1_matrix[3][1] = ExeDataOut[223:208];
                source_1_matrix[3][2] = ExeDataOut[239:224];
                source_1_matrix[3][3] = ExeDataOut[255:240];
                end //Matrix 1 end
            if (address[11:0] == 1) begin //If writing to source 2, parse the word into the matrix
                source_2_matrix[0][0] = ExeDataOut[15:0];
                source_2_matrix[0][1] = ExeDataOut[31:16];
                source_2_matrix[0][2] = ExeDataOut[47:32];
                source_2_matrix[0][3] = ExeDataOut[63:48];
                
                source_2_matrix[1][0] = ExeDataOut[79:64];
                source_2_matrix[1][1] = ExeDataOut[95:80];
                source_2_matrix[1][2] = ExeDataOut[111:96];
                source_2_matrix[1][3] = ExeDataOut[127:112];
                
                source_2_matrix[2][0] = ExeDataOut[143:128];
                source_2_matrix[2][1] = ExeDataOut[159:144];
                source_2_matrix[2][2] = ExeDataOut[175:160];
                source_2_matrix[2][3] = ExeDataOut[191:176]; 
                
                source_2_matrix[3][0] = ExeDataOut[207:192];
                source_2_matrix[3][1] = ExeDataOut[223:208];
                source_2_matrix[3][2] = ExeDataOut[239:224];
                source_2_matrix[3][3] = ExeDataOut[255:240];
                end //Matrix 2 end
            end //if write is 0 end
        
        if (address[11:0] == 3) begin
        $display("I made it inside the Matrix ALU operation block");
        case(operation)
            Mmult1: begin //4x4 times 4x4
                    //for (integer i = 0; i < 4; i++) begin : rows
                      //  for (integer j = 0; j < 4; j++) begin : cols
                        //    result_matrix[i][j] = 0;
                          //  for (integer k = 0; k < 4; k++) begin : elements
                            //    result_matrix[i][j] += source_1_matrix[i][k] * source_2_matrix[k][j];
                          //  end
                       // end
                   // end
                   matrixALU_registers[result][15:0] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][0]) + (source_1_matrix[0][1]*source_2_matrix[1][0]) + (source_1_matrix[0][2]*source_2_matrix[2][0]) + (source_1_matrix[0][3]*source_2_matrix[3][0]);
                   matrixALU_registers[result][31:16] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][1]) + (source_1_matrix[0][1]*source_2_matrix[1][1]) + (source_1_matrix[0][2]*source_2_matrix[2][1]) + (source_1_matrix[0][3]*source_2_matrix[3][1]);
                   matrixALU_registers[result][47:32] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][2]) + (source_1_matrix[0][1]*source_2_matrix[1][2]) + (source_1_matrix[0][2]*source_2_matrix[2][2]) + (source_1_matrix[0][3]*source_2_matrix[3][2]);
                   matrixALU_registers[result][63:48] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][3]) + (source_1_matrix[0][1]*source_2_matrix[1][3]) + (source_1_matrix[0][2]*source_2_matrix[2][3]) + (source_1_matrix[0][3]*source_2_matrix[3][3]);
                   
                   matrixALU_registers[result][79:64] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][0]) + (source_1_matrix[1][1]*source_2_matrix[1][0]) + (source_1_matrix[1][2]*source_2_matrix[2][0]) + (source_1_matrix[1][3]*source_2_matrix[3][0]);
                   matrixALU_registers[result][95:80] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][1]) + (source_1_matrix[1][1]*source_2_matrix[1][1]) + (source_1_matrix[1][2]*source_2_matrix[2][1]) + (source_1_matrix[1][3]*source_2_matrix[3][1]);
                   matrixALU_registers[result][111:96] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][2]) + (source_1_matrix[1][1]*source_2_matrix[1][2]) + (source_1_matrix[1][2]*source_2_matrix[2][2]) + (source_1_matrix[1][3]*source_2_matrix[3][2]);
                   matrixALU_registers[result][127:112] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][3]) + (source_1_matrix[1][1]*source_2_matrix[1][3]) + (source_1_matrix[1][2]*source_2_matrix[2][3]) + (source_1_matrix[1][3]*source_2_matrix[3][3]);
                   
                   matrixALU_registers[result][143:128] = 
                   (source_1_matrix[2][0]*source_2_matrix[0][0]) + (source_1_matrix[2][1]*source_2_matrix[1][0]) + (source_1_matrix[2][2]*source_2_matrix[2][0]) + (source_1_matrix[2][3]*source_2_matrix[3][0]);
                   matrixALU_registers[result][159:144] = 
                   (source_1_matrix[2][0]*source_2_matrix[0][1]) + (source_1_matrix[2][1]*source_2_matrix[1][1]) + (source_1_matrix[2][2]*source_2_matrix[2][1]) + (source_1_matrix[2][3]*source_2_matrix[3][1]);
                   matrixALU_registers[result][175:160] = 
                   (source_1_matrix[2][0]*source_2_matrix[0][2]) + (source_1_matrix[2][1]*source_2_matrix[1][2]) + (source_1_matrix[2][2]*source_2_matrix[2][2]) + (source_1_matrix[2][3]*source_2_matrix[3][2]);
                   matrixALU_registers[result][191:176]  = 
                   (source_1_matrix[2][0]*source_2_matrix[0][3]) + (source_1_matrix[2][1]*source_2_matrix[1][3]) + (source_1_matrix[2][2]*source_2_matrix[2][3]) + (source_1_matrix[2][3]*source_2_matrix[3][3]);
                   
                   matrixALU_registers[result][207:192] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][0]) + (source_1_matrix[3][1]*source_2_matrix[1][0]) + (source_1_matrix[3][2]*source_2_matrix[2][0]) + (source_1_matrix[3][3]*source_2_matrix[3][0]);
                   matrixALU_registers[result][223:208] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][1]) + (source_1_matrix[3][1]*source_2_matrix[1][1]) + (source_1_matrix[3][2]*source_2_matrix[2][1]) + (source_1_matrix[3][3]*source_2_matrix[3][1]);
                   matrixALU_registers[result][239:224] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][2]) + (source_1_matrix[3][1]*source_2_matrix[1][2]) + (source_1_matrix[3][2]*source_2_matrix[2][2]) + (source_1_matrix[3][3]*source_2_matrix[3][2]);
                   matrixALU_registers[result][255:240] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][3]) + (source_1_matrix[3][1]*source_2_matrix[1][3]) + (source_1_matrix[3][2]*source_2_matrix[2][3]) + (source_1_matrix[3][3]*source_2_matrix[3][3]);
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Mmult1 block~~~~~~~~~~~~~~~~~~~~~~~");
                    matrixALU_registers[status_out] = 256'h1;
                    end //End Mmult1 case
            Mmult2: begin
                    
                    //for (integer i = 0; i < 4; i++) begin : rows
                    //    for (integer j = 0; j < 4; j++) begin : cols
                    //        temp[i][j] = 0;
                    //        for (integer k = 0; k < 2; k++) begin : elements
                    //            row_a[k] = fourByTwo[i][k];
                    //            col_b[k] = twoByFour[k][j];
                    //            temp[i][j] += row_a[k] * col_b[k];
                    //        end
                    //    end
                    //end
                    //result_matrix = temp;
                    matrixALU_registers[result][15:0] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][0]) + (source_1_matrix[0][1]*source_2_matrix[1][0]);
                   matrixALU_registers[result][31:16] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][1]) + (source_1_matrix[0][1]*source_2_matrix[1][1]);
                   matrixALU_registers[result][47:32] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][2]) + (source_1_matrix[0][1]*source_2_matrix[1][2]);
                   matrixALU_registers[result][63:48] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][3]) + (source_1_matrix[0][1]*source_2_matrix[1][3]);
                   
                   matrixALU_registers[result][79:64] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][0]) + (source_1_matrix[1][1]*source_2_matrix[1][0]);
                   matrixALU_registers[result][95:80] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][1]) + (source_1_matrix[1][1]*source_2_matrix[1][1]);
                   matrixALU_registers[result][111:96] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][2]) + (source_1_matrix[1][1]*source_2_matrix[1][2]);
                   matrixALU_registers[result][127:112] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][3]) + (source_1_matrix[1][1]*source_2_matrix[1][3]);
                   
                   matrixALU_registers[result][143:128] = 
                   (source_1_matrix[2][0]*source_2_matrix[0][0]) + (source_1_matrix[2][1]*source_2_matrix[1][0]);
                   matrixALU_registers[result][159:144] = 
                   (source_1_matrix[2][0]*source_2_matrix[0][1]) + (source_1_matrix[2][1]*source_2_matrix[1][1]);
                   matrixALU_registers[result][175:160] = 
                   (source_1_matrix[2][0]*source_2_matrix[0][2]) + (source_1_matrix[2][1]*source_2_matrix[1][2]);
                   matrixALU_registers[result][191:176]  = 
                   (source_1_matrix[2][0]*source_2_matrix[0][3]) + (source_1_matrix[2][1]*source_2_matrix[1][3]);
                   
                   matrixALU_registers[result][207:192] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][0]) + (source_1_matrix[3][1]*source_2_matrix[1][0]);
                   matrixALU_registers[result][223:208] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][1]) + (source_1_matrix[3][1]*source_2_matrix[1][1]);
                   matrixALU_registers[result][239:224] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][2]) + (source_1_matrix[3][1]*source_2_matrix[1][2]);
                   matrixALU_registers[result][255:240] = 
                   (source_1_matrix[3][0]*source_2_matrix[0][3]) + (source_1_matrix[3][1]*source_2_matrix[1][3]);
                    
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Mmult2 block~~~~~~~~~~~~~~~~~~~~~~~");
                    matrixALU_registers[status_out] = 256'h1;
                    end 
            Mmult3: begin
                    
                    //for (integer i = 0; i < 2; i++) begin : rows
                    //    for (integer j = 0; j < 2; j++) begin : cols
                    //        temp_m3[i][j] = 0;
                    //        for (integer k = 0; k < 4; k++) begin : elements
                    //            temp_m3[i][j] += twoByFour[i][k] * fourByTwo[k][j];
                    //        end
                    //    end
                    //end
                    //result_matrix[0] = {temp_m3[1][1],temp_m3[1][0],temp_m3[0][1],temp_m3[0][0]};
                     matrixALU_registers[result][15:0] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][0]) + (source_1_matrix[0][1]*source_2_matrix[1][0]) + (source_1_matrix[0][2]*source_2_matrix[2][0]) + (source_1_matrix[0][3]*source_2_matrix[3][0]);
                   matrixALU_registers[result][31:16] = 
                   (source_1_matrix[0][0]*source_2_matrix[0][1]) + (source_1_matrix[0][1]*source_2_matrix[1][1]) + (source_1_matrix[0][2]*source_2_matrix[2][1]) + (source_1_matrix[0][3]*source_2_matrix[3][1]);
                   matrixALU_registers[result][47:32] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][0]) + (source_1_matrix[1][1]*source_2_matrix[1][0]) + (source_1_matrix[1][2]*source_2_matrix[2][0]) + (source_1_matrix[1][3]*source_2_matrix[3][0]);
                   matrixALU_registers[result][63:48] = 
                   (source_1_matrix[1][0]*source_2_matrix[0][1]) + (source_1_matrix[1][1]*source_2_matrix[1][1]) + (source_1_matrix[1][2]*source_2_matrix[2][1]) + (source_1_matrix[1][3]*source_2_matrix[3][1]);
                   
                    matrixALU_registers[result][255:64] = 0;
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Mmult3 block~~~~~~~~~~~~~~~~~~~~~~~");
                    matrixALU_registers[status_out] = 256'h1;
                    end 
            Madd: begin 
                    matrixALU_registers[result] = matrixALU_registers[source_1] + matrixALU_registers[source_2];
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Madd block~~~~~~~~~~~~~~~~~~~~~~~"); 
                    matrixALU_registers[status_out] = 256'h1;
                    end
            Msub: begin
                   matrixALU_registers[result] = matrixALU_registers[source_1] - matrixALU_registers[source_2];
                   $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Msub block~~~~~~~~~~~~~~~~~~~~~~~");
                   matrixALU_registers[status_out] = 256'h1;
                   end 
            Mtranspose: begin
                    for(integer row = 0; row < 4; row++) begin
                        for(integer col = 0; col < 4; col++) begin 
                            result_matrix[row][col] = source_1_matrix[col][row];
                        end end
                        
                        matrixALU_registers[result] = {result_matrix[3][3], result_matrix[3][2], result_matrix[3][1], result_matrix[3][0],
                                                       result_matrix[2][3], result_matrix[2][2], result_matrix[2][1], result_matrix[2][0],
                                                       result_matrix[1][3], result_matrix[1][2], result_matrix[1][1], result_matrix[1][0],
                                                       result_matrix[0][3], result_matrix[0][2], result_matrix[0][1], result_matrix[0][0]};
                        
            
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Mtranspose block~~~~~~~~~~~~~~~~~~~~~~~");
                    matrixALU_registers[status_out] = 256'h1;
                    end
            Mscale: begin
                   matrixALU_registers[result][15:0] = source_1_matrix[0][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][31:16] = source_1_matrix[0][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][47:32] = source_1_matrix[0][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][63:48] = source_1_matrix[0][3] * matrixALU_registers[source_2];
                   
                   matrixALU_registers[result][79:64] = source_1_matrix[1][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][95:80] = source_1_matrix[1][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][111:96] = source_1_matrix[1][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][127:112] = source_1_matrix[1][3] * matrixALU_registers[source_2];
                   
                   matrixALU_registers[result][143:128] = source_1_matrix[2][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][159:144] = source_1_matrix[2][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][175:160] = source_1_matrix[2][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][191:176] = source_1_matrix[2][3] * matrixALU_registers[source_2];
                   
                   matrixALU_registers[result][207:192] = source_1_matrix[3][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][223:208] = source_1_matrix[3][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][239:224] = source_1_matrix[3][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][255:240] = source_1_matrix[3][3] * matrixALU_registers[source_2];
                    $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the Mscale block~~~~~~~~~~~~~~~~~~~~~~~");
                    matrixALU_registers[status_out] = 256'h1;
                    end
            MscaleIMM: begin
                   matrixALU_registers[result][15:0] = source_1_matrix[0][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][31:16] = source_1_matrix[0][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][47:32] = source_1_matrix[0][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][63:48] = source_1_matrix[0][3] * matrixALU_registers[source_2];
                   
                   matrixALU_registers[result][79:64] = source_1_matrix[1][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][95:80] = source_1_matrix[1][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][111:96] = source_1_matrix[1][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][127:112] = source_1_matrix[1][3] * matrixALU_registers[source_2];
                   
                   matrixALU_registers[result][143:128] = source_1_matrix[2][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][159:144] = source_1_matrix[2][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][175:160] = source_1_matrix[2][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][191:176] = source_1_matrix[2][3] * matrixALU_registers[source_2];
                   
                   matrixALU_registers[result][207:192] = source_1_matrix[3][0] * matrixALU_registers[source_2];
                   matrixALU_registers[result][223:208] = source_1_matrix[3][1] * matrixALU_registers[source_2];
                   matrixALU_registers[result][239:224] = source_1_matrix[3][2] * matrixALU_registers[source_2];
                   matrixALU_registers[result][255:240] = source_1_matrix[3][3] * matrixALU_registers[source_2];
                       
                       $display("~~~~~~~~~~~~~~~~~~~~~~~I'm inside the MscaleIMM block~~~~~~~~~~~~~~~~~~~~~~~");    
                       matrixALU_registers[status_out] = 256'h1;
                       end
            
            default: $display("I have hit the DEFAULT OF THE INT ALU CASE BLOCK");
            endcase
      end
        
        
        end //If address is matix alu end
    end //Always comb end
endmodule