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
	,
	,
	,
	,
	,
	
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
			if(data[0]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[1]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[2]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[3]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[4]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[5]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[6]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[7]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[8]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[9]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[10]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[11]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[12]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[13]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[14]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[15]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[16]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[17]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[18]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[19]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[20]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[21]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[22]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[23]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[24]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[25]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[26]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[27]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[28]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[29]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[30]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[31]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[32]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[33]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[34]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[35]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[36]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[37]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[38]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[39]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[40]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[41]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[42]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[43]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[44]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[45]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[46]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[47]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[48]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[49]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[50]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[51]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[52]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[53]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[54]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[55]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[56]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[57]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[58]) begin
					hash = hash ^ hfunction[ii];
			end
			if(data[59]) begin
					hash = hash ^ 10'b1000010001;
			end
			if(data[60]) begin
					hash = hash ^ 10'b0101101000;
			end
			if(data[61]) begin
					hash = hash ^ 10'b0010101001;
			end
			if(data[62]) begin
					hash = hash ^ 10'b1110101100;
			end
			if(data[63]) begin
					hash = hash ^ 10'b0010000001;
			end


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
