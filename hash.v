module hash(data, hash, clk, rst);
input [63:0]data;
input rst;
input clk;
output reg [9:0]hash;

localparam [9:0] hfunction [63:0] = '{
	10'b0110110101,
	10'b0000100000,
	10'b0101101001,
	10'b0001001100,
	10'b1001011101,
	10'b0101000110,
	10'b1100110001,
	10'b1001111011,
	10'b0010110110,
	10'b1101111111,
	10'b1110101100,
	10'b0001011101,
	10'b0111110010,
	10'b1011111001,
	10'b0011011101,
	10'b1001001010,
	10'b1011000000,
	10'b1010100010,
	10'b0110101110,
	10'b1100001111,
	10'b1000011011,
	10'b1010100001,
	10'b0001110110,
	10'b1111111100,
	10'b0111110000,
	10'b1010011111,
	10'b0011010010,
	10'b0011110110,
	10'b0011110000,
	10'b0110010001,
	10'b0111111101,
	10'b0011000001,
	10'b0001101101,
	10'b0011010010,
	10'b0110001001,
	10'b0100100010,
	10'b0111110100,
	10'b1010011001,
	10'b0010101000,
	10'b0100001100,
	10'b1001111000,
	10'b0011001001,
	10'b1010111011,
	10'b1110101000,
	10'b1101010010,
	10'b1011110001,
	10'b1000101000,
	10'b0010111010,
	10'b1100101100,
	10'b1010001000,
	10'b1000000111,
	10'b0001100001,
	10'b0000001110,
	10'b1101010001,
	10'b1001001011,
	10'b0001000010,
	10'b0010111000,
	10'b0000001000,
	10'b1000010001,
	10'b0001111000,
	10'b0101101000,
	10'b0010101001,
	10'b1110101100,
	10'b0010000001
};
parameter reset = 0, hashing = 1;
reg state;
reg next_state;
integer ii;
always@(state, data) begin
	case(state)
		reset: begin
			hash = 10'd0;
			next_state = hashing;
		end
		hashing: begin
			hash = 10'd0;
			for(ii=0; ii<64; ii=ii+1) begin
				if(data[ii]) begin
					hash = hash ^ hfunction[ii];
				end
			end
		end
		default: begin
			hash = 10'd0;
			next_state = hashing;
		end
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
endmodule
