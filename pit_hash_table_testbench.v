module pit_hash_table_testbench();
reg clk;
reg [63:0]prefix;
reg [4:0]len;
reg [63:0]pit_out_prefix;
reg [4:0]pit_out_len;
reg prefix_ready;
reg out_bit;
reg rst;
wire [11:0]table_entry;
wire pit_in_bit;
wire rejected;

initial begin
	clk = 0;
	prefix_ready = 0;
	rst = 1;
	#50
	rst = 0;
	
	// New request
	prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	len = 63;
	out_bit = 1;
	#200
	$display("New request");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#100
	// New request
	prefix = 64'b0000011011100000111010101011011100000111110000100000011110111101;
	len = 63;
	out_bit = 1;
	#100
	$display("New request");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#100
	// New request that has been requested before
	prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	len = 63;
	out_bit = 1;
	#100
	$display("New request that has been requested before");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#100
	out_bit = 0;
	// Data coming in that has been requested
	pit_out_prefix = 64'b0010010011111101101111111000000010100110111011110111110110100111;
	pit_out_len = 63;
	prefix_ready = 1;
	#100
	$display("Data coming in that has been requested");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);
	#100
	// Data coming in that hasn't been requested
	pit_out_prefix = 64'b0011111111001010100111110010111111110101100011001101011001101000;
	pit_out_len = 63;
	prefix_ready = 1;
	#100
	$display("Data coming in that hasn't been requested");
	$display("Table Entry: %b", table_entry);
	$display("PIT in bit: %b", pit_in_bit);
	$display("Rejected bit: %b", rejected);

end

always #10 clk = ~clk;

pit_hash_table H1(.prefix(prefix), 
		  .len(len),
		  .pit_out_prefix(pit_out_prefix),
		  .pit_out_len(pit_out_len),
		  .prefix_ready(prefix_ready), 
		  .out_bit(out_bit), 
		  .clk(clk), 
		  .rst(rst), 
		  .table_entry(table_entry), 
		  .pit_in_bit(pit_in_bit), 
		  .rejected(rejected));
endmodule