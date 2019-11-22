module DataRegister (
	input clk,
	input reset,
	input load_XMT_register,
	input [7:0] data_bus,
	output reg [7:0] currData
);

// Wait for clk or reset
always@(posedge clk, posedge reset) begin
	if (reset)
		currData <= 8'd0;
	if (load_XMT_register)
		currData <= data_bus;	
end
endmodule