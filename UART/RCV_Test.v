`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
//
// Create Date:   17:10:58 04/23/2017
// Design Name:   RCV
// Module Name:   RCV_Test.v
// Project Name:  UART
////////////////////////////////////////////////////////////////////////////////

module RCV_Test;

	// Inputs
	reg clk;
	reg clr;
	reg TxD;
	reg Ack;

	// Outputs
	wire Req;
	wire [7:0] char;

	// Instantiate the Unit Under Test (UUT)
	RCV uut (
		.clk(clk), 
		.clr(clr), 
		.TxD(TxD), 
		.Ack(Ack), 
		.Req(Req),
		.char(char)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		clr = 0;
		TxD = 1;
		Ack = 0;

		// Wait 100 ns for global reset to finish
		#50;
		clr = 1;
		#50;
		clr = 0;
		#160;
        
		// Add stimulus here
		TxD = 0;
		#160;
		TxD = 1;
		#320;
		TxD = 0;
		#160;
		TxD = 1;
		#320;
		TxD = 0;
		#160;
		TxD = 1;
		#600;
		Ack = 1;
	end
      
		always #10 clk = ~clk;
endmodule

