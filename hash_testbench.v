module hash_testbench();
reg [63:0] pre_hash;
wire [9:0] hash;
reg clk;
reg rst;
integer ii;
initial begin
	clk = 0;
	rst = 1;
	#50
	rst = 0;
	
	for(ii = 0; ii < 1000; ii=ii+1) begin
		pre_hash = ii;
		#1
		$display("%d = %x", ii, hash);
		
	end
	/*len = 5'd2;
	pre_hash = 64'd2;
	#50
	$display("%b", hash);
	#50
	len = 2;
	pre_hash = 64'd3;
	#50
	$display("%b", hash);*/

end

always #10 clk = ~clk;




hash H1(.data(pre_hash), .hash(hash), .clk(clk), .rst(rst));

endmodule