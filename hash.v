module hash(data, hash, clk, rst);
input [63:0]data;
input rst;
input clk;
output reg [5:0]hash;

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
					hash = hash ^ 6'b101001;
			end
			if(data[1]) begin
					hash = hash ^ 6'b011011;
			end
			if(data[2]) begin
					hash = hash ^ 6'b000010;
			end
			if(data[3]) begin
					hash = hash ^ 6'b010110;
			end
			if(data[4]) begin
					hash = hash ^ 6'b000100;
			end
			if(data[5]) begin
					hash = hash ^ 6'b100101;
			end
			if(data[6]) begin
					hash = hash ^ 6'b010100;
			end
			if(data[7]) begin
					hash = hash ^ 6'b110011;
			end
			if(data[8]) begin
					hash = hash ^ 6'b100111;
			end
			if(data[9]) begin
					hash = hash ^ 6'b001011;
			end
			if(data[10]) begin
					hash = hash ^ 6'b110111;
			end
			if(data[11]) begin
					hash = hash ^ 6'b111010;
			end
			if(data[12]) begin
					hash = hash ^ 6'b000101;
			end
			if(data[13]) begin
					hash = hash ^ 6'b011111;
			end
			if(data[14]) begin
					hash = hash ^ 6'b101111;
			end
			if(data[15]) begin
					hash = hash ^ 6'b001101;
			end
			if(data[16]) begin
					hash = hash ^ 6'b100100;
			end
			if(data[17]) begin
					hash = hash ^ 6'b101100;
			end
			if(data[18]) begin
					hash = hash ^ 6'b101010;
			end
			if(data[19]) begin
					hash = hash ^ 6'b011010;
			end
			if(data[20]) begin
					hash = hash ^ 6'b110000;
			end
			if(data[21]) begin
					hash = hash ^ 6'b100001;
			end
			if(data[22]) begin
					hash = hash ^ 6'b101010;
			end
			if(data[23]) begin
					hash = hash ^ 6'b000111;
			end
			if(data[24]) begin
					hash = hash ^ 6'b111111;
			end
			if(data[25]) begin
					hash = hash ^ 6'b011111;
			end
			if(data[26]) begin
					hash = hash ^ 6'b101001;
			end
			if(data[27]) begin
					hash = hash ^ 6'b001101;
			end
			if(data[28]) begin
					hash = hash ^ 6'b001111;
			end
			if(data[29]) begin
					hash = hash ^ 6'b001111;
			end
			if(data[30]) begin
					hash = hash ^ 6'b011001;
			end
			if(data[31]) begin
					hash = hash ^ 6'b011111;
			end
			if(data[32]) begin
					hash = hash ^ 6'b001100;
			end
			if(data[33]) begin
					hash = hash ^ 6'b000110;
			end
			if(data[34]) begin
					hash = hash ^ 6'b001101;
			end
			if(data[35]) begin
					hash = hash ^ 6'b011000;
			end
			if(data[36]) begin
					hash = hash ^ 6'b010010;
			end
			if(data[37]) begin
					hash = hash ^ 6'b011111;
			end
			if(data[38]) begin
					hash = hash ^ 6'b101001;
			end
			if(data[39]) begin
					hash = hash ^ 6'b001010;
			end
			if(data[40]) begin
					hash = hash ^ 6'b010000;
			end
			if(data[41]) begin
					hash = hash ^ 6'b100111;
			end
			if(data[42]) begin
					hash = hash ^ 6'b001100;
			end
			if(data[43]) begin
					hash = hash ^ 6'b101011;
			end
			if(data[44]) begin
					hash = hash ^ 6'b111010;
			end
			if(data[45]) begin
					hash = hash ^ 6'b110101;
			end
			if(data[46]) begin
					hash = hash ^ 6'b101111;
			end
			if(data[47]) begin
					hash = hash ^ 6'b100010;
			end
			if(data[48]) begin
					hash = hash ^ 6'b001011;
			end
			if(data[49]) begin
					hash = hash ^ 6'b110010;
			end
			if(data[50]) begin
					hash = hash ^ 6'b101000;
			end
			if(data[51]) begin
					hash = hash ^ 6'b100000;
			end
			if(data[52]) begin
					hash = hash ^ 6'b000110;
			end
			if(data[53]) begin
					hash = hash ^ 6'b100000;
			end
			if(data[54]) begin
					hash = hash ^ 6'b110101;
			end
			if(data[55]) begin
					hash = hash ^ 6'b100100;
			end
			if(data[56]) begin
					hash = hash ^ 6'b000100;
			end
			if(data[57]) begin
					hash = hash ^ 6'b001011;
			end
			if(data[58]) begin
					hash = hash ^ 6'b001000;
			end
			if(data[59]) begin
					hash = hash ^ 6'b100001;
			end
			if(data[60]) begin
					hash = hash ^ 6'b010110;
			end
			if(data[61]) begin
					hash = hash ^ 6'b001010;
			end
			if(data[62]) begin
					hash = hash ^ 6'b111010;
			end
			if(data[63]) begin
					hash = hash ^ 6'b001000;
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
