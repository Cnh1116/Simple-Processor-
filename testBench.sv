// File Name: testBench.sv
//
// Name: Carson Holland
//
// Date: April 25th, 2023
// 
// File Purpose: Generic Test bench It drives only clock and reset.
// 
// Assistance / Credit: Professor Mark W Welker's code

module TestMatrix  (Clk,nReset);

	output logic Clk,nReset; // we are driving these signals from here. 

	initial begin
		Clk = 0;
		nReset = 1;
	#5 nReset = 0;
	#5 nReset = 1;
	end
	
	always  #5 Clk = ~Clk;

	
	endmodule