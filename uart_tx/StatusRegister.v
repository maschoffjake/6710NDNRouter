module StatusRegister (
	input clear,
	input shift,
	input clk,
	input reset,
	output reg [3:0] bitCount
);

// Wait for for either clk or reset
always@(posedge clk, posedge reset) begin
	if (reset)
		bitCount <= 4'd0;
	if (clear)
		bitCount <= 4'd0;
	if (shift)
		bitCount <= bitCount + 1;
end
endmodule
