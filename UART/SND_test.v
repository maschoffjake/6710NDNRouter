`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
//
// Create Date:   13:52:10 04/23/2017
// Design Name:   SND
// Module Name:   SND_test.v
// Project Name:  UART
////////////////////////////////////////////////////////////////////////////////

module SND_test;

	// Inputs
	reg clk;
	reg clr;
	reg Req;
	reg [7:0] char;

	// Outputs
	wire RxD;
	wire Ack;

	// Instantiate the Unit Under Test (UUT)
	SND uut (
		.clk(clk), 
		.clr(clr), 
		.Req(Req), 
		.char(char), 
		.RxD(RxD), 
		.Ack(Ack)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		clr = 0;
		Req = 0;
		char = 8'b11011011;
		
		// Wait 100 ns for global reset to finish
		#100;
      clr = 1;
		#20
		clr = 0;
		#10
		// Add stimulus here
		Req = 1;
		#2000
		Req = 0;
	end
      
		always #10 clk = ~clk;
endmodule

