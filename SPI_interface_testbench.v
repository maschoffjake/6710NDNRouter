module spi_interface_module();

// SPI interfaces
wire sclk;
wire mosi;
reg miso;
wire cs;

// Overall inputs
reg clk;
reg rst;

// Receiving output
wire          RX_valid;  // Valid pulse for 1 cycle for RX byte to know data is ready
wire		  output_shift_register;

// Transferring input
reg               TX_valid;                   // Valid pulse for 1 cycle for TX byte
reg [7:0] input_shift_register;

reg [2:0] state;
reg [8:0] rx_count;
reg transmitting;
parameter tx = 0, waiting = 1, next = 2, sending = 3, reset = 4, rx = 5, idle = 6;    

// Instantiate the module
spi_interface spi_interface_module(
    .mosi(mosi),
    .miso(miso),
    .clk(clk),
    .rst(rst),
    .RX_valid(RX_valid),
	.output_shift_register(output_shift_register),
    .TX_valid(TX_valid),
	.input_shift_register(input_shift_register)
);

/*
    VALUES USED FOR SIMULATION
*/
reg start_incoming_packet;
reg start_outgoing_packet;

reg [7:0]         packet_meta_data_test;     
reg [63:0]        packet_prefix_test;
reg [255:0]       packet_data_test;
reg [327:0]		  transmitting_data_test;
reg [328:0] 	  receiving_data_test;

// assign input_shift_register = transmitting_data_test[325:318];

initial begin
    TX_valid = 0;
    start_incoming_packet = 0;
    start_outgoing_packet = 0;
	transmitting = 0;
	packet_meta_data_test = 8'b00101000;
    packet_prefix_test = 64'd129;
	rx_count = 329;
    packet_data_test = "here is data";
	transmitting_data_test = {packet_meta_data_test, packet_prefix_test, packet_data_test};
	receiving_data_test = {1'b0, packet_meta_data_test, packet_prefix_test, packet_data_test};
	clk = 0;
    rst = 0;
	state = 0;
    #2;
    rst = 1;
    #2;
    rst = 0;
    #2;

    // Start outgoing packet

end


always
begin
	// Create clock
	#10 clk = ~clk;
	if(clk) begin
		if(transmitting) begin
			case(state)
			tx:
			begin
				TX_valid <= 1;
				state <= waiting;
			end
			waiting:
			begin
				TX_valid <= 0;
				state <= next;
			end
			next:
			begin
				input_shift_register = transmitting_data_test[327:320];
				transmitting_data_test = transmitting_data_test << 8;
			end
			endcase
		end
		else begin
			case(state)
				tx: begin
					if(rx_count > 0) begin
					miso = receiving_data_test[328];
					rx_count = rx_count - 1;
					receiving_data_test = receiving_data_test << 1;
					end
					else begin
						state <= idle;
					end
				end
				idle: begin
				end
			endcase
		end
	end
end

endmodule
