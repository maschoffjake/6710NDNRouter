module hash_testbench();
reg [63:0] pre_hash;
reg [4:0] len;
wire [9:0] hash;
reg clk;
reg rst;

initial begin
	clk = 0;
	rst = 1;
	#50
	rst = 0;
	len = 1;
	pre_hash = 1'b1;
	#50
	$display("%b", hash);
	#50
	len = 2;
	pre_hash = 2'b10;
	#50
	$display("%b", hash);
	#50
	len = 2;
	pre_hash = 2'b11;
	#50
	$display("%b", hash);

end

always #10 clk = ~clk;




hash H1(.data(pre_hash), .len(len), .hash(hash), .clk(clk), .rst(rst));

endmodule