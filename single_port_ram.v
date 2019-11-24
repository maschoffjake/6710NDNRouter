module single_port_ram
(
	input [7:0] data,
	input [9:0] addr,
	input [9:0] byte,
	input we, clk,
	output [7:0] q
);

	// Declare the RAM variable
	reg [8192:0] ram[9:0]; //1024 entries of 1024 bytes 
	
	// Variable to hold the registered read address
	reg [5:0] addr_reg;
	
	always @ (posedge clk)
	begin
	// Write
		if (we)
			ram[addr][byte*8 +:8] <= data; //weird selector syntax, but should work
		
		addr_reg <= addr;
		
	end
		
	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = ram[addr_reg][byte*8 +:8];
	
endmodule
