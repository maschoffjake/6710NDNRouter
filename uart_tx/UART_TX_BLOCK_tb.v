module UART_TX_BLOCK_tb ();

reg Byte_ready;
reg T_byte;
reg clk;
reg reset;
reg load_XMT_register;
reg [7:0] data_bus;
wire serial_out;

UART_TX_BLOCK DUT (
	.Byte_ready(Byte_ready),
	.T_byte(T_byte),
	.clk(clk),
	.reset(reset),
	.load_XMT_register(load_XMT_register),
	.data_bus(data_bus),
	.serial_out(serial_out)
);

initial begin
	// Reset and set all values to 0
	reset = 1'b1;
	Byte_ready = 1'b0;
	load_XMT_register = 1'b0;
	T_byte = 1'b0;
	data_bus = 8'd0;
	#100;
	reset = 1'b0;
	
	// Set data bus value, wait a little
	data_bus = 8'b11110000;
	#20;

	// Load the data into data Register
	load_XMT_register = 1'b1;
	#20;
	load_XMT_register = 1'b0;

	// Set Byte_ready to high
	Byte_ready = 1'b1;
	#20;
	Byte_ready = 1'b0;

	// Now set T_byte
	T_byte = 1'b1;
	#20;
	T_byte = 1'b0;

	// TESTING ANOTHER BIN VAL, wait around 400 ns to finish
	#400;
	
	// Set data bus value, wait a little
	data_bus = 8'b11010011;
	#20;

	// Load the data into data Register
	load_XMT_register = 1'b1;
	#20;
	load_XMT_register = 1'b0;

	// Set Byte_ready to high
	Byte_ready = 1'b1;
	#20;
	Byte_ready = 1'b0;

	// Now set T_byte
	T_byte = 1'b1;
	#20;
	T_byte = 1'b0;
end

initial begin
	// Create clock
	clk = 1'b0;
	#100;
	forever #10 clk = ~clk;
end

endmodule
