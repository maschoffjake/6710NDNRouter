module pit_hash_table_testbench();
reg clk;
reg [63:0]SPI_to_PIT_prefix;
reg [63:0]FIB_to_PIT_prefix;
reg [5:0]length;
reg [7:0]FIB_to_PIT_metadata;
reg prefix_ready;
reg out_bit;
reg rst;
wire [10:0]table_entry;
wire pit_in_bit;
wire [7:0]metadata;
wire rejected;
wire interest_packet;

initial begin
	clk = 0;
	prefix_ready = 0;
	rst = 1;
	#50
	rst = 0;
	#50
	// New request
	SPI_to_PIT_prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	length = 63;
	out_bit = 1;
	$display("New request");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#20
	out_bit = 0;
	#100
	// New request
	SPI_to_PIT_prefix = 64'b0000011011100000111010101011011100000111110000100000011110111101;
	length = 63;
	out_bit = 1;
	$display("New outgoing request");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#20
	out_bit = 0;
	#100
	// New request that has been requested before
	SPI_to_PIT_prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	length = 63;
	out_bit = 1;
	$display("New outgoing request that has been requested before");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#20
	out_bit = 0;
	#100
	// Data coming in that has been requested
	FIB_to_PIT_prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	FIB_to_PIT_metadata = 63;
	prefix_ready = 1;
	$display("Incoming data that has been requested");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#20
	prefix_ready = 0;
	#100
	// Data coming in that hasn't been requested
	FIB_to_PIT_prefix = 64'b0011111111001010100111110010111111110101100011001101011001101000;
	FIB_to_PIT_metadata = 63;
	prefix_ready = 1;
	$display("Incoming data that hasn't been requested");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	$display("Data Packet: %b", interest_packet);
	#20
	prefix_ready = 0;
	#100
	// Data coming in that has been requested
	FIB_to_PIT_prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	FIB_to_PIT_metadata = {2'b01, 6'd63};
	prefix_ready = 1;
	$display("Incoming interest packet that has been requested");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	$display("Data Packet: %b", interest_packet);

end

always #10 clk = ~clk;

pit_hash_table H1(.SPI_to_PIT_prefix(SPI_to_PIT_prefix), 
		  .FIB_to_PIT_prefix(FIB_to_PIT_prefix),
		  .FIB_to_PIT_metadata(FIB_to_PIT_metadata),
		  .length(length),
		  .prefix_ready(prefix_ready), 
		  .out_bit(out_bit), 
		  .clk(clk), 
		  .rst(rst), 
		  .table_entry(table_entry), 
		  .meta_data(meta_data),
		  .pit_in_bit(pit_in_bit), 
		  .rejected(rejected),
		  .interest_packet(interest_packet));
endmodule