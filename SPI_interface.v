/*
    This SPI module is used to from NDN --> outgoing interface.
    In this set up the NDN module acts as the master, and the outgoing interface
    acts as the slave.

    PROTOCOL:   start bit -> low
                end bit   -> low
                
    Data Packet:
                1st byte:
                    1st bit - X
                    2nd bit - type of packet (1 for interest, 0 for data)
                    3rd - 8th bit: length of the packet prefix content header (MSB sent first)
                2nd - 9th byte:
                    All 64-bits represent the prefix content header (MSB sent first)
                10th - 266st byte:
                    All 256 of these bytes represent the actual data associated with the data packet

    Interest Packet:
                1st byte:
                    1st bit - X
                    2nd bit - type of packet (1 for interest, 0 for data)
                    3rd - 8th bit: length of the packet prefix content header (MSB sent first)
                2nd - 9th byte:
                    All 64-bits represent the prefix content header (MSB sent first) of the requested data
				10th - 18th byte:
					All 64-bits represent the longest matching prefix.
*/
module spi_interface(

    // SPI interfaces
    output sclk,
    output reg mosi,
    input miso,
    output cs,

    // Overall inputs
    input clk,
    input rst,

    // Receiving output
    output reg              RX_valid,               // Valid pulse for 1 cycle for RX byte to know data is ready
    output reg [7:0]        output_shift_register,  // Used to send data to the FIB 

    // Transferring input
    input               TX_valid,                   // Valid pulse for 1 cycle for TX byte
    input [7:0]         input_shift_register
);

// Counts for registers (where to insert bits)
reg [2:0] meta_data_count;
reg [5:0] prefix_count;
reg [7:0] data_count;

// Reg's to store data to send to the fib
reg [7:0]    packet_meta_data;
reg [63:0]   packet_prefix;
reg [255:0]  packet_data;

// Flag for if the current packet being received is a interest/data
reg isInterestPacket;

// Used for setting flags high
localparam HIGH = 1;
localparam LOW = 0;

// State for receving
reg [2:0] receiving_state;

// Counts for what bytes we are on
reg [2:0] prefix_byte_count;
reg [4:0] data_byte_count;

// State names
localparam idle = 0, receiving_meta_packet_info = 1, receiving_packet_prefix = 2, receiving_packet_data = 3, send_metadata_to_fib = 4, send_prefix_to_fib = 5, send_data_to_fib = 6;

/* 
    Just assign the chip select low for now, since we are only interfacing with one interface.
    Could easily change this module to allow for more chip selects, so the chip could interface
    with multiple outgoing interfaces.
*/
assign cs = LOW;
assign sclk = clk;


/*
    RECEIVING DATA STATE MACHINE
*/
always@(posedge clk, posedge rst) begin
    if (rst) begin
        RX_valid <= 0;
        receiving_state <= idle;
        packet_meta_data <= 8'd0;
        packet_prefix <= 64'd0;
        packet_data <= 255'd0;
        prefix_byte_count <= 0;
        data_byte_count <= 0;
    end
    else begin
        case (receiving_state)
            idle: begin
                RX_valid <= 0;
                packet_meta_data <= 0;
                packet_prefix <= 0;
                packet_data <= 0;
                meta_data_count <= 7;
                prefix_count <= 63;
                data_count <= 255;
                prefix_byte_count <= 7;
                data_byte_count <= 32;

                // Wait for miso to go low (start bit)
                if (!miso) begin
                    receiving_state <= receiving_meta_packet_info;
                end
            end 
            receiving_meta_packet_info: begin
                // First bit of a packet is a filler bit, so grab second. If it's high, interest packet!
                if (meta_data_count == 6) begin
                    if (miso) begin
                        isInterestPacket = HIGH;
                    end
                    else begin
                        isInterestPacket = LOW;
                    end
                    // Set the packet type in the packet container
                    packet_meta_data[meta_data_count] <= miso;
                    meta_data_count <= meta_data_count - 1;
                end
                // Grab after the 2nd bit to continue to fill in the meta packet info
                else if (meta_data_count > 1) begin
                    packet_meta_data[meta_data_count] <= miso;
                end
                // Once all meta data has been received, time to receive packet prefix!
                else if (meta_data_count == 0) begin
                    packet_meta_data[meta_data_count] <= miso;
                    receiving_state <= receiving_packet_prefix;
                end
                meta_data_count <= meta_data_count - 1;
            end
            receiving_packet_prefix: begin
                // Time to move states 
                if (prefix_count == 0) begin
                    // If this was an interest packet, done receving, set bit high so FIB can grab data and go back to idle
                    if (isInterestPacket) begin
                        RX_valid <= HIGH;
                        receiving_state <= send_data_to_fib;
                    end
                    // Otherwise we must receive the data content of the packet as well
                    else begin
                        receiving_state <= receiving_packet_data;
                    end    
                end

                // Save data and increment counters
                packet_prefix[prefix_count] <= miso; 
                prefix_count <= prefix_count - 1;
            end
            receiving_packet_data: begin
                // Time to move states and let FIB know that the data packet is and forward data!
                if (data_count == 0) begin
                    RX_valid <= HIGH;
                    receiving_state <= send_data_to_fib;
                end
                packet_data[data_count] <= miso;
                data_count <= data_count - 1;
            end
            send_metadata_to_fib: begin
                output_shift_register <= packet_meta_data;
                receiving_state <= send_prefix_to_fib;
            end
            send_prefix_to_fib: begin
                if (prefix_byte_count == 0) begin
                    // Done sending prefix data!
                    if (isInterestPacket) begin
                        // Don't need to send data to FIB
                        receiving_state <= idle;
                    end
                    // Otherwise we need to send data
                    else begin
                        receiving_state <= send_data_to_fib;
                    end
                end
                // Grab the 8 MSB and shift them out to grab next 8 MSBs
                output_shift_register <= (packet_prefix[63:56]) << 8;
                prefix_byte_count <= prefix_byte_count - 1;
            end
            send_data_to_fib: begin
                if (data_byte_count == 0) begin
                    // Done sendind data! Back to idle
                    receiving_state <= idle;
                end
                // Grab the 8 MSB and shift them out to grab next 8 MSBs
                output_shift_register <= (packet_data[255:248]) << 8;
                data_byte_count <= data_byte_count - 1;
            end
            default: begin
                receiving_state <= idle;
            end
        endcase
    end
end

// Counts for registers (where to grab bits)
reg [2:0] meta_data_input_count;
reg [5:0] prefix_input_count;
reg [7:0] data_input_count;
reg transferring_data_packet;

// Save input values when flag goes high
reg [7:0]    packet_meta_data_input_save;
reg [63:0]   packet_prefix_input_save;
reg [255:0]  packet_data_input_save;

parameter packet_meta = 1, packet_prefix_state = 2, packet_data_state = 3, send_meta_data = 4, send_prefix = 5, send_data = 6;
reg [2:0] transmitting_state;

/*
    TRANSFERRING DATA STATE MACHINE
*/

always@(posedge clk, posedge rst)
    if (rst) begin
        transmitting_state <= idle;
        meta_data_input_count <= 0;
        prefix_input_count <= 0;
        data_input_count <= 0;
        mosi <= HIGH;
        transferring_data_packet <= LOW;
        packet_meta_data_input_save <= 0;
        packet_data_input_save <= 0;
        packet_prefix_input_save <= 0;
    end
    else begin
        case (transmitting_state)
            idle: begin
                // Set counts to MSB of each registers
				meta_data_input_count <= 1;
                prefix_input_count <= 8;
                data_input_count <= 32;
                transferring_data_packet <= LOW; // Default to low

                if (TX_valid) begin
                    // Send start bit to start transfer and change states
                    mosi <= LOW;
                    transmitting_state <= packet_meta;
                end
                // Keep data line high (so the interface knows nothing is transferring)
                else begin
                    mosi <= HIGH;
                end
            end
			packet_meta: begin
				if(meta_data_input_count > 0) begin
				packet_meta_data_input_save <= input_shift_register;
				meta_data_input_count = meta_data_input_count - 1;
				end
				else begin
				transmitting_state <= packet_prefix_state;
				end
			end
			packet_prefix_state: begin
				if(prefix_input_count > 0) begin
					packet_prefix_input_save <= (packet_prefix_input_save << 8) + input_shift_register;
					prefix_input_count <= prefix_input_count - 1;
				end
				else begin
					transmitting_state <= packet_data_state;
				end
			end
			packet_data_state: begin
				if(data_input_count > 0) begin
					packet_data_input_save <= (packet_data_input_save << 8) + input_shift_register;	
					data_input_count = data_input_count - 1;			
				end
				else begin
					transmitting_state <= send_meta_data;
				end
			end 
            send_meta_data: begin
                if (meta_data_input_count == 0) begin
                    transmitting_state <= send_prefix;
                end 
                else if (meta_data_input_count == 6) begin
                    transferring_data_packet <= !packet_meta_data_input_save[meta_data_input_count]; // See if the packet being transferred is a data packet, so we know what we are transferring
                end
                mosi <= packet_meta_data_input_save[meta_data_input_count];
                meta_data_input_count <= meta_data_input_count - 1;
            end
            send_prefix: begin
                if (prefix_input_count == 0) begin
                    // Check to see if we are transferring data
                    if (transferring_data_packet) begin
                        transmitting_state <= send_data;
                    end
                    // If not, go back to idle
                    else begin
                        transmitting_state <= idle;
                    end
                end
                mosi <= packet_prefix_input_save[prefix_input_count];
                prefix_input_count <= prefix_input_count - 1;
            end
            send_data: begin
                if (data_input_count == 0) begin
                    transmitting_state <= idle;
                end
                mosi <= packet_data_input_save[data_input_count];
                data_input_count <= data_input_count - 1;
            end
        endcase
    end
endmodule