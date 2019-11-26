module pit_hash_table(prefix, pit_out_prefix, pit_out_metadata, length, prefix_ready, out_bit, clk, rst, table_entry, meta_data, pit_in_bit, rejected, interest_packet);
input [63:0] prefix;
input [63:0] pit_out_prefix;
input [7:0] pit_out_metadata;
input [5:0] length; // Added
input prefix_ready;
input out_bit;
input clk;
input rst;

output reg [10:0] table_entry;
output reg [7:0] meta_data; // Added
output reg pit_in_bit;
output reg rejected;
output reg interest_packet; // Added

reg [11:0] cache [1023:0]; //Hash table with 1024 entries
reg [9:0] current_address;
reg [4:0] state;
reg [4:0] next_state;
reg [63:0] pre_hash;

wire [9:0]hash;

integer ii;

parameter block_size = 1; //1024 bytes per address row
parameter reset = 0, idle = 1, get_hash = 2;

always @(state, out_bit, prefix_ready) begin
	case (state)
		// Initialize all values
		reset: begin
			current_address = 0;
			rejected = 0;
			next_state = idle;
			pre_hash = 0;
			pit_in_bit = 0;
			table_entry = 0;
			meta_data = 0;
			interest_packet = 0;
			for(ii = 0; ii < 1024; ii=ii+1)
				cache[ii] = 0;
		end
		// Wait for input from User or FIB
		idle: begin
			if(prefix_ready || out_bit) begin
				table_entry = 0;
				pit_in_bit = 0;
				interest_packet = 0;
				// Set values based on who raised flag
				if(out_bit) begin
					meta_data = {2'b01, length};
					pre_hash = prefix;
					next_state = get_hash;
				end
				if(prefix_ready) begin
					meta_data = pit_out_metadata;
					pre_hash = pit_out_prefix;
					next_state = get_hash;
				end
			end
		end
		// Hash is ready now, so get table entry or create new one
		get_hash: begin
			if(cache[hash][11]) begin
				if(prefix_ready) begin
					if(meta_data[6] && cache[hash][10]) begin
						interest_packet = 1;
					end
					cache[hash][10] = 1;
				end
				table_entry = cache[hash][10:0];
				pit_in_bit = 1;
				next_state = idle;
			end
			else begin
				if(out_bit) begin
					cache[hash][9:0] = current_address;
					current_address = current_address + block_size;
					cache[hash][11] = 1;
					table_entry = cache[hash][10:0];
					pit_in_bit = 1;
					next_state = idle;
				end
				// If FIB got data that wasn't requested, reject
				else begin
					rejected = 1;
					next_state = idle;
				end
			end
		end
		default:
			next_state = reset;
	endcase
end

always @(posedge clk, posedge rst) begin
	if(rst) begin
		state <= reset;
	end
	else begin
		state <= next_state;		
	end
end

hash H1(pre_hash, hash, clk, rst);

endmodule