`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
// 
// Create Date:    15:25:03 04/24/2017 
// Module Name:    UART_Main 
//////////////////////////////////////////////////////////////////////////////////
module UART_Main(
    input TxD,
    input clk,
    input clr,
    output [7:0] LEDS,
    output RxD
    );
	
	wire slowclk;
	wire Ack, Req;
	wire [7:0] char;
	
	// Wire everything together.
	ClkDivider clkdiv(clk, clr, slowclk);
	// Comment these out to run test bench
	/*RCV receive(slowclk, clr, TxD, Ack, Req, char);
	SND send(slowclk, clr, Req, char, RxD, Ack);*/
	
	// Uncomment to run test bench
	RCV receive(clk, clr, TxD, Ack, Req, char);
	SND send(clk, clr, Req, char, RxD, Ack);

	assign LEDS = char;
endmodule
