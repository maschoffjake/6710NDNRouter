/*
    This SPI module is used to from NDN --> MCU (user).
    In this set up the NDN module acts as the slave, and the MCU acts as the
    master.

    PROTOCOL:   start bit -> low
                end bit   -> low
                

    Interest Packet:
                1st byte:
                    1st bit - X
                    2nd bit - type of packet (1 for interest, 0 for data)
                    3rd - 8th bit: length of the packet prefix content header (MSB sent first)
                2nd - 9th byte:
                    All 64-bits represent the prefix content header (MSB sent first) of the requested data
				10th - 18th byte:
					All 64-bits represent the longest matching prefix.

    Data Packet:
                1st byte:
                    1st bit - X
                    2nd bit - type of packet (1 for interest, 0 for data)
                    3rd - 8th bit: X
                2nd - 257th byte:
                    All these bytes represent the actual data associated with the data packet being sent to the user

    MCU only needs to send out interest packets, and can only receive data packets!

*/
module spi_mcu(
    input mosi,
    output reg miso,
    input cs,

    // Overall inputs
    input clk,
    input rst,

    // Receiving output
    output reg [7:0]        output_shift_register,  // Used to send data to the FIB 


	input [7:0] 	PIT_to_SPI_data,
	input [63:0] 	PIT_to_SPI_prefix,
	output reg 		SPI_to_PIT_bit,
	output reg [5:0]    	SPI_to_PIT_length,
	output reg [63:0]   	SPI_to_PIT_prefix
);


// Counts for registers (where to insert bits)
reg [2:0] length_data_count;
reg [5:0] prefix_count;
reg [7:0] data_count;

// Reg's to store data to send to the fib
reg [63:0] SPI_prefix;
reg [255:0]  packet_data;

// Used for setting flags high
localparam HIGH = 1;
localparam LOW = 0;

// State for receving
reg [2:0] receiving_state;

// Counts for what bytes we are on
reg [2:0] prefix_byte_count;
reg [4:0] data_byte_count;

// State names
localparam idle = 0, receiving_packet_length = 1, receiving_packet_prefix = 2, send_data_to_pithash = 3;

/* 
    Just assign the chip select low for now, since we are only interfacing with one interface.
    Could easily change this module to allow for more chip selects, so the chip could interface
    with multiple outgoing interfaces.
*/


/*
    RECEIVING DATA STATE MACHINE
*/
always@(posedge clk, posedge rst) begin
    if (rst) begin
        receiving_state <= idle;
        SPI_to_PIT_length <= 6'd0;
        SPI_to_PIT_prefix <= 64'd0;
        prefix_byte_count <= 0;
    end
    else begin
        case (receiving_state)
            idle: begin
				SPI_to_PIT_bit <= 0;
                SPI_to_PIT_length <= 0;
                SPI_to_PIT_prefix <= 0;
				prefix_count <= 63;
                length_data_count <= 5;
                prefix_byte_count <= 7;

                // Wait for miso to go low (start bit)
                if (!mosi) begin
                    receiving_state <= receiving_packet_length;
                end
            end 
            receiving_packet_length: begin
                // First bit of a packet is a filler bit, so grab second. If it's high, interest packet!
				if (length_data_count > 0) begin
                    SPI_to_PIT_length[length_data_count] <= mosi;
					length_data_count <= length_data_count - 1;
                end
                // Once all meta data has been received, time to receive packet prefix!
                else if (length_data_count == 0) begin
                    SPI_to_PIT_length[length_data_count] <= mosi;
                    receiving_state <= receiving_packet_prefix;
                end
            end
            receiving_packet_prefix: begin
                // Time to move states 
				if(prefix_count > 0) begin
				   	SPI_to_PIT_prefix[prefix_count] <= mosi;
                    prefix_count <= prefix_count - 1; 
				end
                else if (prefix_count == 0) begin
			       SPI_to_PIT_prefix[prefix_count] <= mosi; 
                   receiving_state <= send_data_to_pithash;  
                end

            end
            send_data_to_pithash: begin
				SPI_to_PIT_bit <= 1;
                receiving_state <= idle;
            end
            default: begin
                receiving_state <= idle;
            end
        endcase
    end
end

// Counts for registers (where to grab bits)
reg [5:0] prefix_input_count;
reg [7:0] data_input_count;
reg transferring_data_packet;

// Save input values when flag goes high
reg [255:0]  SPI_to_USER_data;

localparam packet_data_state = 1, send_prefix = 2, send_data = 3;
reg [2:0] transmitting_state;

/*
    TRANSFERRING DATA STATE MACHINE
*/

always@(posedge clk, posedge rst)
    if (rst) begin
        transmitting_state <= idle;
        prefix_input_count <= 0;
        data_input_count <= 0;
        miso <= HIGH;
        transferring_data_packet <= LOW;
        SPI_to_USER_data <= 0;
    end
    else begin
        case (transmitting_state)
            idle: begin
                // Set counts to MSB of each registers
                data_input_count <= 31;
				prefix_input_count <= 63;
                transferring_data_packet <= LOW; // Default to low

                if (PIT_to_SPI_bit) begin
                    // Send start bit to start transfer and change states
                    transmitting_state <= packet_data_state;
                end
                // Keep data line high (so the interface knows nothing is transferring)
                else begin
                    miso <= HIGH;
                end
            end
			packet_data_state: begin
				if(data_input_count > 0) begin
					SPI_to_USER_data <= (SPI_to_USER_data << 8) + PIT_to_SPI_data;	
					data_input_count <= data_input_count - 1;			
				end
				if(data_input_count == 1) begin
					transmitting_state <= send_prefix;
					SPI_prefix = PIT_to_SPI_prefix;
                 	data_input_count <= 255;
				end
			end 
            send_prefix: begin
                if (prefix_input_count == 0) begin
                    // Check to see if we are transferring data
                    transmitting_state <= send_data;
                end
                miso <= SPI_prefix[31];
				SPI_prefix <= SPI_prefix << 1;
                prefix_input_count <= prefix_input_count - 1;
            end
            send_data: begin
                if (data_input_count == 0) begin
                    transmitting_state <= idle;
                end
                miso <= SPI_to_USER_data[255];
				SPI_to_USER_data <= SPI_to_USER_data << 1;
                data_input_count <= data_input_count - 1;
            end
			default: begin
				transmitting_state <= idle;
			end
        endcase
    end
endmodule