module pit_hash_table(prefix, len, pit_out_prefix, pit_out_len, prefix_ready, out_bit, clk, rst, table_entry, pit_in_bit, rejected);
input [63:0]prefix;
input [5:0]len;
input [63:0] pit_out_prefix;
input [5:0] pit_out_len;
input prefix_ready;
input out_bit;
input clk;
input rst;
output reg [63:0] table_entry;
output reg pit_in_bit;
output reg rejected;

reg [5:0] length;
reg [63:0] cache [1023:0]; //Hash table with 1024 entries
reg [61:0] current_address;
parameter block_size = 1024; //1024 bytes for data
integer ii;
reg [4:0] state;
reg [4:0] next_state;
parameter reset = 0, idle = 1, get_hash = 2;
wire [9:0]hash;
reg [63:0] pre_hash;

always @(state, out_bit, prefix_ready) begin
	case (state)
		reset: begin
			current_address <= 0;
			rejected <= 0;
			next_state <= idle;
			pre_hash <= 0;
			pit_in_bit <= 0;
			table_entry <= 0;
			for(ii = 0; ii < 1024; ii=ii+1)
				cache[ii] <= 0;
		end
		idle: begin
			if(prefix_ready || out_bit) begin
				table_entry <= 0;
				pit_in_bit <= 0;
				if(out_bit) begin
					pre_hash <= prefix;
					length <= len;
					next_state <= get_hash;
				end
				if(prefix_ready) begin
					pre_hash <= pit_out_prefix;
					length <= pit_out_len;
					next_state <= get_hash;
				end
			end
		end
		get_hash: begin
			if(cache[hash][63]) begin
				if(prefix_ready) begin
					cache[hash][62] <= 1;
				end
				table_entry <= cache[hash][63:0];
				pit_in_bit <= 1;
				next_state <= idle;
			end
			else begin
				if(out_bit) begin
					cache[hash][61:0] = current_address;
					current_address = current_address + block_size;
					cache[hash][63] = 1;
					table_entry = cache[hash][63:0];
					pit_in_bit = 1;
					next_state = idle;
				end
				else begin
					rejected <= 1;
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

hash H1(pre_hash, length, hash, clk, rst);

endmodule