module hash(data, len, hash, clk, rst);
input [63:0]data;
input [5:0] len;
input rst;
input clk;
output reg [9:0]hash;

reg [9:0] hfunction[63:0];
parameter reset = 0, hashing = 1;
reg state;
reg next_state;
integer ii;
always@(state, data) begin
	case(state)
		reset: begin
			hash <= 10'd0;
			hfunction[0] <= 10'b0110110101;
			hfunction[1] <= 10'b0000100000;
			hfunction[2] <= 10'b0101101001;
			hfunction[3] <= 10'b0001001100;
			hfunction[4] <= 10'b1001011101;
			hfunction[5] <= 10'b0101000110;
			hfunction[6] <= 10'b1100110001;
			hfunction[7] <= 10'b1001111011;
			hfunction[8] <= 10'b0010110110;
			hfunction[9] <= 10'b1101111111;
			hfunction[10] <= 10'b1110101100;
			hfunction[11] <= 10'b0001011101;
			hfunction[12] <= 10'b0111110010;
			hfunction[13] <= 10'b1011111001;
			hfunction[14] <= 10'b0011011101;
			hfunction[15] <= 10'b1001001010;
			hfunction[16] <= 10'b1011000000;
			hfunction[17] <= 10'b1010100010;
			hfunction[18] <= 10'b0110101110;
			hfunction[19] <= 10'b1100001111;
			hfunction[20] <= 10'b1000011011;
			hfunction[21] <= 10'b1010100001;
			hfunction[22] <= 10'b0001110110;
			hfunction[23] <= 10'b1111111100;
			hfunction[24] <= 10'b0111110000;
			hfunction[25] <= 10'b1010011111;
			hfunction[26] <= 10'b0011010010;
			hfunction[27] <= 10'b0011110110;
			hfunction[28] <= 10'b0011110000;
			hfunction[29] <= 10'b0110010001;
			hfunction[30] <= 10'b0111111101;
			hfunction[31] <= 10'b0011000001;
			hfunction[32] <= 10'b0001101101;
			hfunction[33] <= 10'b0011010010;
			hfunction[34] <= 10'b0110001001;
			hfunction[35] <= 10'b0100100010;
			hfunction[36] <= 10'b0111110100;
			hfunction[37] <= 10'b1010011001;
			hfunction[38] <= 10'b0010101000;
			hfunction[39] <= 10'b0100001100;
			hfunction[40] <= 10'b1001111000;
			hfunction[41] <= 10'b0011001001;
			hfunction[42] <= 10'b1010111011;
			hfunction[43] <= 10'b1110101000;
			hfunction[44] <= 10'b1101010010;
			hfunction[45] <= 10'b1011110001;
			hfunction[46] <= 10'b1000101000;
			hfunction[47] <= 10'b0010111010;
			hfunction[48] <= 10'b1100101100;
			hfunction[49] <= 10'b1010001000;
			hfunction[50] <= 10'b1000000111;
			hfunction[51] <= 10'b0001100001;
			hfunction[52] <= 10'b0000001110;
			hfunction[53] <= 10'b1101010001;
			hfunction[54] <= 10'b1001001011;
			hfunction[55] <= 10'b0001000010;
			hfunction[56] <= 10'b0010111000;
			hfunction[57] <= 10'b0000001000;
			hfunction[58] <= 10'b1000010001;
			hfunction[59] <= 10'b0001111000;
			hfunction[60] <= 10'b0101101000;
			hfunction[61] <= 10'b0010101001;
			hfunction[62] <= 10'b1110101100;
			hfunction[63] <= 10'b0010000001;
			next_state <= hashing;
		end
		hashing: begin
			hash = 10'd0;
			for(ii=0; ii<64; ii=ii+1) begin
				if(data[ii]) begin
					hash = hash ^ hfunction[ii];
				end
			end
		end
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
endmodule