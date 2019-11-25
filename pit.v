module PIT(table_entry, address, current_byte, in_data, read_data, out_data, write_enable, in_bit, out_bit, data_packet, start_bit, fib_out, clk, reset);

// I changed this to 11 bits b/c pit never checks requested bit
input [10:0] table_entry; // it's easier to just pass the whole table entry instead of concatenating it
input [7:0] in_data, read_data;
input in_bit, out_bit, data_packet, clk, reset;

output reg [9:0] address;
output reg [9:0] current_byte;
output reg [7:0] out_data;
output reg start_bit, write_enable, fib_out;

reg [2:0] state;
reg [9:0] pit_address;
reg [9:0] memory_count;


parameter IDLE = 3'b000;
parameter RECEIVING_PIT = 3'b001;
parameter RECEIVING_FIB = 3'b010;
parameter MEMORY_IN = 3'b011;
parameter MEMORY_OUT = 3'b100;
parameter RESET = 3'b111;
parameter received_bit = 10;

always@(posedge clk, posedge reset)
if(reset) begin
	state <= RESET;
end else begin
begin
	case(state)
	IDLE:
	begin
		if(out_bit)
		begin
			state <= RECEIVING_PIT;
		end
		if(in_bit)
		begin
			state <= RECEIVING_FIB;
		end
	end

	RECEIVING_PIT:
	begin
		if(table_entry[received_bit])
		begin
			state <= MEMORY_OUT;
			pit_address <= table_entry[9:0];
			memory_count <= 0;
			current_byte <= 0;
		end
		else
		begin
			fib_out <= 1;
			state <= RESET;
		end
	end
	RECEIVING_FIB:
	begin
		memory_count <= 0;
		pit_address <= table_entry[9:0];
		current_byte <= 0;
		start_bit <= 1;
		if(data_packet) begin // If FIB sent an interest packet and the PIT has that packet, set fib_out and start_bit high to notify it has the data
			state <= MEMORY_OUT; // otherwise just the start bit is high and the FIB will know it doesn't have the data
			fib_out <= 1;
		end 
		else begin
			write_enable <= 1;
			state <= MEMORY_IN;
		end
	end

	MEMORY_IN:
	begin
		if(memory_count < 1023)
		begin
			out_data <= in_data;
			address <= pit_address;
			current_byte <= current_byte + 1;
			memory_count <= memory_count + 1;
		end
		else
		begin
			state <= IDLE;
			start_bit <= 0;
			write_enable <= 0;
		end
	end

	MEMORY_OUT:
	begin
		if(memory_count < 1023)
		begin
			out_data <= read_data;
			address <= pit_address;
			current_byte <= current_byte + 1;
			memory_count <= memory_count + 1;
		end
		else
		begin
			state <= IDLE;
		end
	end

	RESET:
	begin
		fib_out <= 0;
		memory_count <= 0;
		current_byte <= 0;
		state <= IDLE;
	end
	default:
	begin
		state <= RESET;
	end
	endcase
end
end
endmodule 
