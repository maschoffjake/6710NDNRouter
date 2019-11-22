`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kent Allen & Blaze Kotsenburg
// 
// Create Date:    16:55:45 04/20/2017 
// Module Name:    RCV 
//////////////////////////////////////////////////////////////////////////////////
module RCV(clk, clr, TxD, Ack, Req, char);

	input clk, clr, TxD, Ack;
	output reg Req;
	output reg [7:0] char;
	parameter sampleStartBit = 3;
	parameter sampleBit = 7;
	parameter A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7, I=8, J=9, K=10;
	reg [2:0] count;
	reg [3:0] state; 
	reg [3:0] nextState;
	
	always @(posedge clk, posedge clr)
	begin
		if(clr)
		begin
			state <= A;
			char <= 0;
			count <= 0;
		end
		else
		begin
			case(state)
			A: //Listening for TxD to go low
			begin
				if(~TxD)
				begin
				
					count <= count + 1'b1;
					
					// Count to 4 to start sampling in the middle of the bits.
					if(count == sampleStartBit)
					begin
						state <= B;
						count <= 0;
					end
				end
				
				else
				begin
					state <= A;
					count <= 0;
				end
			end
			B: // Start writing the incoming data to the 8-bit bus
			begin
				// Count to 8 to sample in the middle of the bit
				if(count == sampleBit)
				begin
					count <= 0;
					char[0] <= TxD;
					state <= C;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			
			C: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[1] <= TxD;
					state <= D;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			D: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[2] <= TxD;
					state <= E;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			E: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[3] <= TxD;
					state <= F;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			F: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[4] <= TxD;
					state <= G;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			G: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[5] <= TxD;
					state <= H;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			H: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[6] <= TxD;
					state <= I;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			I: //Writing cont'd
			begin
				if(count == sampleBit)
				begin
					count <= 0;
					char[7] <= TxD;
					state <= J;
				end
				else
				begin
					count <= count + 1'b1;
				end
			end
			endcase
			
			// After writing data to the bus, start the 4-cycle handshake
			if(state > I)
			begin
				state <= nextState;
			end
		end
	end
	
	always @(*)
	begin
		nextState <= 0;
		Req <= 0;
		case(state)
			J: // Set Req high, signaling SND to start using the data on the bus
			begin
				Req <=1;
				nextState <= K;
			end
			
			K: // Once Ack goes high SND is done with the data and we can receive
				// the next char from the terminal
			begin
			
				if(Ack)
				begin
					nextState <= A;
					Req <= 0;
				end
				else
				begin
					Req <= 1;
					nextState <= K;
				end
			end
		endcase
	end
	
endmodule
