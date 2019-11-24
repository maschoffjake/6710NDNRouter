module single_port_ram
(
	input [7:0] data,
	input [9:0] addr,
	input [9:0] byte,
	input we, clk, rst,
	output [7:0] q
);

	// Declare the RAM variable
	reg [8192:0] ram[9:0]; //1024 entries of 1024 bytes 
	
	// Variable to hold the registered read address
	reg [5:0] addr_reg;

	integer ii;
	
	always @ (posedge clk)
	begin
		if(rst) begin
			for(ii = 0; ii < 1024; ii=ii+1) begin
				ram[ii] <= 0;
			end
		end
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
