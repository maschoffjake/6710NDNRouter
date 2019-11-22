module TransmitterController (
	input Byte_ready,
	input T_byte,
	input reset,
	input clk,
	input [3:0] bitCount,
	output reg shiftFlag,
	output reg clearFlag,
	output reg load_shift_register,
	output reg startFlag
);

// 3 states: idle, waiting for T_byte, and sending
reg [1:0] state, nextState;

// Used for calculating the nextState values
always@(state, Byte_ready, T_byte, reset, bitCount) begin

	// Default output logic
	load_shift_register <= 1'b0;
	clearFlag <= 1'b0;
	shiftFlag <= 1'b0;
	startFlag <= 1'b0;

	case(state)	
		// Idle state
		2'b00:
			begin
				// Check to see if the byte is ready to transmit
				if (Byte_ready) begin
					load_shift_register <= 1'b1;
					nextState <= 2'b01;
				end
				else
					nextState <= 2'b00;
			end
		// Load the shift register
		2'b01:
			begin
				if (T_byte) begin
					startFlag <= 1'b1;
					nextState <= 2'b10;
				end
				else
					nextState <= 2'b01;
			end
		// Now start sending data
		2'b10:
			begin
				if (bitCount == 9) begin
					clearFlag <= 1'b1;
					nextState <= 2'b00;
				end
				else begin
					nextState <= 2'b10;
					shiftFlag <= 1'b1;
				end
			end
		// This state shouldn't be reached, but if it is just reset to state 0
		2'b11:
			nextState <= 2'b00;
	endcase
end

// Used for setting the actual state values
always@(posedge clk, posedge reset) begin
	// Check for reset
	if (reset)
		state <= 2'b00;
	else
		state <= nextState;
end

endmodule