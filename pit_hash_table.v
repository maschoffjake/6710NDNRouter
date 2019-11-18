module pit_hash_table(prefix, len, in_bit, out_bit, clk, rst, table_entry, pit_in_bit);
input [63:0]prefix;
input [4:0]len;
input in_bit;
input out_bit;
input clk;
input rst;
output reg table_entry;
output reg pit_in_bit;

reg [63:0] cache [1023:0]; //Hash table with 1024 entries
reg [61:0] current_address;
parameter block_size = 1024; //1024 bytes for data
integer ii;
reg [4:0] state;
reg [4:0] next_state;
parameter reset = 0, idle = 1, get_hash = 2;
wire [9:0]hash;
reg [61:0] pre_hash;

always @(state, out_bit, in_bit) begin
	case (state)
		reset: begin
			current_address <= 0;
			next_state <= idle;
			pre_hash <= 0;
			pit_in_bit <= 0;
			for(ii = 0; ii < 1024; ii=ii+1)
				cache[ii] <= 0;
		end
		idle: begin
			if(in_bit || out_bit) begin
				pit_in_bit <= 0;
				pre_hash <= prefix[61:0];
				next_state <= get_hash;
			end
		end
		get_hash: begin
			if(cache[hash][63]) begin
				table_entry <= cache[hash];
				pit_in_bit <= 1;
				next_state <= idle;
			end
			else begin
				if(out_bit) begin
					cache[hash][61:0] = current_address;
					current_address = current_address + block_size;
					cache[hash][63] = 1;
					table_entry = cache[hash];
					pit_in_bit = 1;
					next_state = idle;
				end
				else begin
					next_state <= idle;
				end
			end
		end
		default:
			next_state <= reset;
	endcase
end

always @(posedge clk, rst) begin
	if(rst) begin
		state <= reset;
	end
	else begin
		state <= next_state;		
	end
end

hash H1(pre_hash, len, hash, clk, rst);

endmodule