module pit_testbench();

reg [11:0] table_entry_tb;
reg [7:0] in_data_tb, read_data_tb;
reg in_bit_tb, out_bit_tb, clk_tb, reset_tb;

wire [9:0] address_tb;
wire [7:0] out_data_tb;
wire start_bit_tb, write_enable_tb, fib_out_tb;

reg [2:0] state;

PIT p0 (
.table_entry(table_entry_tb), 
.address(address_tb), 
.in_data(in_data_tb), 
.read_data(read_data_tb), 
.out_data(out_data_tb), 
.write_enable(write_enable_tb), 
.in_bit(in_bit_tb), 
.out_bit(out_bit_tb), 
.start_bit(start_bit_tb),
.fib_out(fib_out_tb), 
.clk(clk_tb), 
.reset(reset_tb)
);

parameter idle = 3'b000;
parameter entry = 3'b001;
parameter waiting = 3'b010;



initial
begin
	table_entry_tb = 64'b00100010001;
	//table_entry_tb = 64'b1001000100010001000100010001000100010001000100010001000100010001;
	read_data_tb = 8'b11111111;
	in_data_tb = 8'd0;
	clk_tb = 0;
	reset_tb = 0;
	in_bit_tb = 0;
	out_bit_tb = 0;
	state = idle;
end

always
begin
	#10 clk_tb = ~clk_tb;
	if(clk_tb)
	begin
		case(state)
		idle:
		begin
			in_bit_tb <= 1;
			state <= entry;
			$display("fib_out=%d", fib_out_tb);
			$display("out_data=%d", out_data_tb);
			$display("address=%b", address_tb);	
			$display("write_enable=%d", write_enable_tb);
			$display("start_bit=%d", start_bit_tb);
		end
		entry:
		begin
			state <= waiting;
			$display("fib_out=%d", fib_out_tb);
			$display("out_data=%d", out_data_tb);	
			$display("address=%b", address_tb);
			$display("write_enable=%d", write_enable_tb);
			$display("start_bit=%d", start_bit_tb);
		end
		waiting:
		begin
			//read_data_tb <= read_data_tb - 1;
			if(in_data_tb == 254)
				in_data_tb <= 0;
			in_data_tb <= in_data_tb + 1;
			in_bit_tb <= 0;
			$display("fib_out=%d", fib_out_tb);
			$display("out_data=%d", out_data_tb);	
			$display("address=%b", address_tb);
			$display("write_enable=%d", write_enable_tb);
			$display("start_bit=%d", start_bit_tb);
		end
		endcase
	end
end
endmodule
