module UART (Data_bus, Byte_ready, T_byte, clk, reset, Serial_out);

input clk, reset, Byte_ready, T_byte;
input [7:0] Data_bus;
output reg Serial_out;

reg [7:0] shift_reg;
reg [3:0] count;
reg [1:0] state;

// Three states are saved and the number of bits expected from the transmission
parameter IDLE = 2'b00;
parameter WAITING = 2'b01;
parameter SENDING = 2'b10;
parameter bit_count = 4'b0101;

always@(posedge clk or posedge reset)
begin

	if(reset)
	begin
		shift_reg = 8'b0;
		count = 4'b0;
		Serial_out = 1;
		state = IDLE;
	end

	case(state)
	/* In the IDLE state it waits for the data_bus to be ready and loads that into the shift_reg.
	   In the assignment, it included the LOAD_XMT_datareg but I didn't know any way to incorporate it
	   into this part where it would be necessary and not redundant. So when the data is ready I load it
	   straight into the shift register.		
	*/
	IDLE: 
	begin
		if(Byte_ready)
		begin
			shift_reg = Data_bus;
			state = WAITING;
		end
	end
	// In the waiting state once the host has sent the flag that the transmission is ready I send the 
	// starting bit and move onto the sending state
	WAITING:
	begin
		if(T_byte)
		begin
			state = SENDING;
			Serial_out = 0;
			count = count + 1;
		end
	end
	// In the sending state I set the serial out to be the LSB of the shift reg and then shift the reg to
	// the right by one. I used non blocking statements because I wasn't sure how to store and save the 
	// output value while also shifting in the same block. So I chose to use blocking statements.
	SENDING:
	begin
		if(count >= bit_count)
		begin
			Serial_out = 1;
			state = IDLE;
			count = 0;
		end
		else
		begin
			Serial_out = shift_reg[0];
			shift_reg = shift_reg >> 1;
			count = count + 1;
		end
	end
	default:
	begin
		state = IDLE;
	end
	endcase
end
endmodule 
