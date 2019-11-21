module fib_table_testbench ();

// PIT INPUTS
reg [63:0] pit_in_prefix,
reg [5:0] pit_in_len,
reg fib_out_bit,
reg start_send_to_pit,
reg rejected,

// DATA INPUTS
reg [5:0] data_in_len,
reg [63:0] data_in_prefix,
reg data_ready,
reg [7:0] data_in,

// HASH INPUTS
reg [9:0] hash,

// OVERALL INPUTS 
reg clk,
reg rst,

// PIT OUTPUTS
wire [5:0] pit_out_len,
wire [63:0] pit_out_prefix,
wire prefix_ready,
wire [7:0] out_data,

// DATA OUTPUTS
wire [63:0] prefix_out,
wire [5:0] len_out,
output clk_out,

// HASH OUTPUTS
wire [63:0] hash_prefix_in,
wire [5:0] hash_len_in

fib_table DUT (
    pit_in_prefix,
    pit_in_len,
    fib_out_bit,
    start_send_to_pit,
    rejected,

    data_in_len,
    data_in_prefix,
    data_ready,
    data_in,

    hash,

    clk,
    rst,

    pit_out_len,
    pit_out_prefix,
    prefix_ready,
    out_data,

    prefix_out,
    len_out,
    output clk_out,

    hash_prefix_in,
    hash_len_in
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
