module UART_TX_BLOCK (
	input Byte_ready,
	input T_byte,
	input clk,
	input reset,
	input load_XMT_register,
	input [7:0] data_bus,
	output serial_out
);

// Wires to connect modules
wire load_shift_register;
wire clearFlag;
wire shiftFlag;
wire startFlag;
wire [7:0] dataRegisterToShiftRegister;

// Instantiate the DataRegister module, and connect it to the shift register
DataRegister dataRegister (
	.clk(clk),
	.reset(reset),
	.load_XMT_register(load_XMT_register),
	.data_bus(data_bus),
	.currData(dataRegisterToShiftRegister)
);

// Instatiate the StatusRegister and grab the output to connect to Controller
wire [3:0] bitCount;
StatusRegister statusRegister (
	.clk(clk),
	.reset(reset),
	.shift(shiftFlag),
	.clear(clearFlag),
	.bitCount(bitCount)
);

// Instatiate the TransmitterController, and pass values between modules
TransmitterController transmitterController (
	.Byte_ready(Byte_ready),
	.clk(clk),
	.reset(reset),
	.T_byte(T_byte),
	.bitCount(bitCount),
	.load_shift_register(load_shift_register),
	.clearFlag(clearFlag),
	.shiftFlag(shiftFlag),
	.startFlag(startFlag)
);

// Instantiate the ShiftRegister
ShiftRegister shiftRegister (
	.clk(clk),
	.reset(reset),
	.dataFromDataRegister(dataRegisterToShiftRegister),
	.load_shift_register(load_shift_register),
	.serial_out(serial_out),
	.startFlag(startFlag),
	.shiftFlag(shiftFlag)
);

endmodule