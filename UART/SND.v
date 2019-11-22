`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
// 
// Create Date:    15:51:42 04/22/2017 
// Module Name:    SND 
//////////////////////////////////////////////////////////////////////////////////
module SND(clk, clr, Req, char, RxD, Ack);

	input clk, clr, Req;
	input [7:0] char;
	output reg Ack, RxD;
	reg [3:0] state, nextState;
	reg [2:0] count;
	parameter A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7, I=8, J=9, K=10, L=11, M=12, N=13;
	
	always @(posedge clk, posedge clr)
	begin
		if(clr)
		begin
			state <= 0;
			count <= 0;
		end
		else
		begin
			// Slow the clock down by a factor of 8 in order to send
			// data out at 9600 baud. This slows down things other than
			// sending the data out but makes the logic more simple.
			if(count == 3'b111)
			begin
				state <= nextState;
				count <= 0;
			end
			else
			begin
				count <= count + 1'b1;
			end
		end
	end
	
	always @(*)
	begin
		nextState <= 0;
		Ack <= 0;
		RxD <= 1;
		
		case(state)
			A: // Once Req goes high we are ready to use the data on the bus
			begin
				if(Req)
				begin
					nextState <= B;
				end
				
				else
					nextState <= A;
			end
			
			B: // Pull RxD low for start bit
			begin
				RxD <= 0;
				nextState <= C;
			end
			C: // Send send data from the bus to RxD
			begin
				RxD <= char[0];
				nextState <= D;
			end
			D: // Send send data from the bus to RxD
			begin
				RxD <= char[1];
				nextState <= E;
			end
			E: // Send send data from the bus to RxD
			begin
				RxD <= char[2];
				nextState <= F;
			end
			F: // Send send data from the bus to RxD
			begin
				RxD <= char[3];
				nextState <= G;
			end
			G: // Send send data from the bus to RxD
			begin
				RxD <= char[4];
				nextState <= H;
			end
			H: // Send send data from the bus to RxD
			begin
				RxD <= char[5];
				nextState <= I;
			end
			I: // Send send data from the bus to RxD
			begin
				RxD <= char[6];
				nextState <= J;
			end
			J: // Send send data from the bus to RxD
			begin
				RxD <= char[7];
				nextState <= K;
			end
			K: // Pull RxD high for stop bit
			begin
				RxD <= 1;
				nextState <= L;
			end
			L: // Pull RxD high for stop bit
			begin
				RxD <= 1;
				nextState <= M;
			end
			M: // Raise Ack high to signal RCV that we are done using
				// the data on the bus.
			begin
				Ack <= 1;
				nextState <= N;
			end
			
			N: // Wait for Req to go low; then we can start over
			begin
				
				if(~Req)
				begin
					Ack <= 0;
					nextState <= A;
				end
				
				else
				begin
					Ack <= 1;
					nextState <= N;
				end
			end
		endcase
		
	end
endmodule
