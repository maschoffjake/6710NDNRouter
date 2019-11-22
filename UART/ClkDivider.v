`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
// 
// Create Date:    16:42:32 04/20/2017 
// Module Name:    ClkDivider 
//////////////////////////////////////////////////////////////////////////////////
module ClkDivider(clk, clr, slowclk);

	input clk, clr;
	output reg slowclk; // Output clock rate
	parameter countTo = 651; // Half clock period
	reg [9:0] count;
	
	always @(posedge clk, posedge clr)
	begin
	
		if(clr)
		begin
			count <= 0;
		end
		
		else
		begin
		
			if(count == countTo) // Every 651 ticks, flip clk
			begin
				slowclk <= ~slowclk;
				count <= 0;
			end
			
			else
				count <= count + 1'b1;
		end
	end
endmodule
