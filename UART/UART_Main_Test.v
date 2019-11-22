`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
//
// Create Date:   17:34:09 04/25/2017
// Design Name:   UART_Main
// Module Name:   C:/Users/Kent/Source/Repos/3700-Final-Project/UART/UART_Main_Test.v
// Project Name:  UART
////////////////////////////////////////////////////////////////////////////////

module UART_Main_Test;

	// Inputs
	reg TxD;
	reg clk;
	reg clr;

	// Outputs
	wire [7:0] LEDS;
	wire RxD;

	// Instantiate the Unit Under Test (UUT)
	UART_Main uut (
		.TxD(TxD), 
		.clk(clk), 
		.clr(clr), 
		.LEDS(LEDS), 
		.RxD(RxD)
	);

	initial begin
		// Initialize Inputs
		TxD = 1;
		clk = 0;
		clr = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		clr = 1;
		#160;
		clr = 0;
		#160;
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
	end
      
		always #10 clk = ~clk;
endmodule

