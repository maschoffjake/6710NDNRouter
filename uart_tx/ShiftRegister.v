module ShiftRegister (
	input clk,
	input reset,
	input [7:0] dataFromDataRegister,
	input load_shift_register,
	input startFlag,
	input shiftFlag,
	output reg serial_out
);

reg [3:0] currentBit;
reg [7:0] currentData;

always@(posedge clk) begin

	// Precedence order: reset --> stop-bit --> transmission start --> shift bit
	if (reset) begin
		currentBit <= 3'd0;
		serial_out <= 1'b1;
	end	// When the bit is at 8, we want the 9th bit to be high (stop-bit), so we must intiate this change on 8th bit
	else if (currentBit == 8) begin
		currentBit <= 3'd0;
		serial_out <= 1'b1;
	end
	else if (startFlag) begin
		// Send out start bit
		serial_out <= 1'b0;
		currentBit <= 3'd0;
	end
	else if (shiftFlag) begin
		// Grab current bit and sent it out, increment counter
		serial_out <= currentData[currentBit];
		currentBit <= currentBit + 1;
	end

	// Check to see if we need to grab new data
	if (load_shift_register)
		currentData <= dataFromDataRegister;

end

endmodule
