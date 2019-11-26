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
reg [7:0]    SPI_to_FIB_metadata;
reg [63:0]   SPI_to_FIB_prefix;
reg [255:0]  SPI_to_FIB_data;

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
localparam idle = 0, INTERFACE_to_SPI_meta_state = 1, INTERFACE_to_SPI_prefix_state = 2, INTERFACE_to_SPI_packet_state = 3, SPI_to_FIB_meta_state = 4, SPI_to_FIB_prefix_state = 5, SPI_to_FIB_data_state = 6;

/* 
    Just assign the chip select low for now, since we are only interfacing with one interface.
    Could easily change this module to allow for more chip selects, so the chip could interface
    with multiple outgoing interfaces.
*/
assign cs = LOW;


/*
    RECEIVING DATA STATE MACHINE
*/
always@(posedge clk, posedge rst) begin
    if (rst) begin
        RX_valid <= 0;
        receiving_state <= idle;
        SPI_to_FIB_metadata <= 8'd0;
        SPI_to_FIB_prefix <= 64'd0;
        SPI_to_FIB_data <= 255'd0;
        prefix_byte_count <= 0;
        data_byte_count <= 0;
    end
    else begin
        case (receiving_state)
            idle: begin
                RX_valid <= 0;
                SPI_to_FIB_metadata <= 0;
                SPI_to_FIB_prefix <= 0;
                SPI_to_FIB_data <= 0;
                meta_data_count <= 7;
                prefix_count <= 63;
                data_count <= 255;
                prefix_byte_count <= 7;
                data_byte_count <= 31;

                // Wait for miso to go low (start bit)
                if (!miso) begin
                    receiving_state <= INTERFACE_to_SPI_meta_state;
                end
            end 
            INTERFACE_to_SPI_meta_state: begin
                // First bit of a packet is a filler bit, so grab second. If it's high, interest packet!
                if (meta_data_count == 6) begin
                    if (miso) begin
                        isInterestPacket = HIGH;
                    end
                    else begin
                        isInterestPacket = LOW;
                    end
                    // Set the packet type in the packet container
                    SPI_to_FIB_metadata[meta_data_count] <= miso;
                    meta_data_count <= meta_data_count - 1;
                end
                // Grab after the 2nd bit to continue to fill in the meta packet info
                else if (meta_data_count > 1) begin
                    SPI_to_FIB_metadata[meta_data_count] <= miso;
                end
                // Once all meta data has been received, time to receive packet prefix!
                else if (meta_data_count == 0) begin
                    SPI_to_FIB_metadata[meta_data_count] <= miso;
                    receiving_state <= INTERFACE_to_SPI_prefix_state;
                end
                meta_data_count <= meta_data_count - 1;
            end
            INTERFACE_to_SPI_prefix_state: begin
                // Time to move states 
                if (prefix_count == 0) begin
                    // If this was an interest packet, done receving, set bit high so FIB can grab data and go back to idle
                    if (isInterestPacket) begin
                        RX_valid <= HIGH;
                        receiving_state <= SPI_to_FIB_meta_state;
                    end
                    // Otherwise we must receive the data content of the packet as well
                    else begin
                        receiving_state <= INTERFACE_to_SPI_packet_state;
                    end    
                end

                // Save data and increment counters
                SPI_to_FIB_prefix[prefix_count] <= miso; 
                prefix_count <= prefix_count - 1;
            end
            INTERFACE_to_SPI_packet_state: begin
                // Time to move states and let FIB know that the data packet is and forward data!
                if (data_count == 0) begin
                    RX_valid <= HIGH;
                    receiving_state <= SPI_to_FIB_meta_state;
                end
                SPI_to_FIB_data[data_count] <= miso;
                data_count <= data_count - 1;
            end
            SPI_to_FIB_meta_state: begin
                output_shift_register <= SPI_to_FIB_metadata;
                receiving_state <= SPI_to_FIB_prefix_state;
            end
            SPI_to_FIB_prefix_state: begin
                if (prefix_byte_count == 0) begin
                    // Done sending prefix data!
                    if (isInterestPacket) begin
                        // Don't need to send data to FIB
                        receiving_state <= idle;
                    end
                    // Otherwise we need to send data
                    else begin
                        receiving_state <= SPI_to_FIB_data_state;
                    end
                end
                // Grab the 8 MSB and shift them out to grab next 8 MSBs
                output_shift_register <= SPI_to_FIB_prefix[63:56];
				SPI_to_FIB_prefix <= SPI_to_FIB_prefix << 8;
                prefix_byte_count <= prefix_byte_count - 1;
            end
            SPI_to_FIB_data_state: begin
                if (data_byte_count == 0) begin
                    // Done sendind data! Back to idle
                    receiving_state <= idle;
                end
                // Grab the 8 MSB and shift them out to grab next 8 MSBs
                output_shift_register <= SPI_to_FIB_data[255:248];
				SPI_to_FIB_data <= SPI_to_FIB_data << 8;
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
reg [7:0]    FIB_to_SPI_metadata;
reg [63:0]   FIB_to_SPI_prefix;
reg [255:0]  FIB_to_SPI_data;

parameter FIB_to_SPI_meta_state = 1, FIB_to_SPI_prefix_state = 2, FIB_to_SPI_data_state = 3, SPI_to_INTERFACE_meta = 4, SPI_to_INTERFACE_prefix = 5, SPI_to_INTERFACE_data = 6;
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
        FIB_to_SPI_metadata <= 0;
        FIB_to_SPI_data <= 0;
        FIB_to_SPI_prefix <= 0;
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
                    transmitting_state <= FIB_to_SPI_meta_state;
                end
                // Keep data line high (so the interface knows nothing is transferring)
                else begin
                    mosi <= HIGH;
                end
            end
			FIB_to_SPI_meta_state: begin
				if(meta_data_input_count > 0) begin
				FIB_to_SPI_metadata <= input_shift_register;
				meta_data_input_count <= meta_data_input_count - 1;
				end
				if(meta_data_input_count == 1) begin
				transmitting_state <= FIB_to_SPI_prefix_state;
				meta_data_input_count <= 7;
				end
			end
			FIB_to_SPI_prefix_state: begin
				if(prefix_input_count > 0) begin
					FIB_to_SPI_prefix <= (FIB_to_SPI_prefix << 8) + input_shift_register;
					prefix_input_count <= prefix_input_count - 1;
				end
				if(prefix_input_count == 1) begin
					transmitting_state <= FIB_to_SPI_data_state;
                	prefix_input_count <= 63;
				end
			end
			FIB_to_SPI_data_state: begin
				if(data_input_count > 0) begin
					FIB_to_SPI_data <= (FIB_to_SPI_data << 8) + input_shift_register;	
					data_input_count <= data_input_count - 1;			
				end
				if(data_input_count == 1) begin
					transmitting_state <= SPI_to_INTERFACE_meta;
                 	data_input_count <= 255;
				end
			end 
            SPI_to_INTERFACE_meta: begin
                if (meta_data_input_count == 0) begin
                    transmitting_state <= SPI_to_INTERFACE_prefix;
                end 
                else if (meta_data_input_count == 6) begin
                    transferring_data_packet <= !FIB_to_SPI_metadata[meta_data_input_count]; // See if the packet being transferred is a data packet, so we know what we are transferring
                end
                mosi <= FIB_to_SPI_metadata[meta_data_input_count];
                meta_data_input_count <= meta_data_input_count - 1;
            end
            SPI_to_INTERFACE_prefix: begin
                if (prefix_input_count == 0) begin
                    // Check to see if we are transferring data
                    if (transferring_data_packet) begin
                        transmitting_state <= SPI_to_INTERFACE_data;
                    end
                    // If not, go back to idle
                    else begin
                        transmitting_state <= idle;
                    end
                end
                mosi <= FIB_to_SPI_prefix[prefix_input_count];
                prefix_input_count <= prefix_input_count - 1;
            end
            SPI_to_INTERFACE_data: begin
                if (data_input_count == 0) begin
                    transmitting_state <= idle;
                end
                mosi <= FIB_to_SPI_data[data_input_count];
                data_input_count <= data_input_count - 1;
            end
        endcase
    end
endmodule