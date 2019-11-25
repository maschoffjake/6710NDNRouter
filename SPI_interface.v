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
                10th - 521st byte:
                    All 512 of these bytes represent the actual data associated with the data packet

    Interest Packet:
                1st byte:
                    1st bit - X
                    2nd bit - type of packet (1 for interest, 0 for data)
                    3rd - 8th bit: length of the packet prefix content header (MSB sent first)
                2nd - 9th byte:
                    All 64-bits represent the prefix content header (MSB sent first) of the requested data
*/
module spi_interface(

    // SPI interfaces
    output sclk,
    output mosi,
    input miso,
    output cs,

    // Overall inputs
    input clk,
    input rst,

    // Receiving output
    output reg          RX_valid,  // Valid pulse for 1 cycle for RX byte to know data is ready
    output reg [7:0]    packet_meta_data,
    output reg [63:0]   packet_prefix,
    output reg [255:0]  packet_data,

    // Transferring input
    input               TX_valid,                   // Valid pulse for 1 cycle for TX byte
    input [7:0]         packet_meta_data_input,     
    input [63:0]        packet_prefix_input,
    input [255:0]       packet_data_input 
);

// Counts for registers (where to insert bits)
reg [2:0] meta_data_count;
reg [5:0] prefix_count;
reg [7:0] data_count;

// Flag for if the current packet being received is a interest/data
reg isInterestPacket;

// Used for setting flags high
localparam HIGH = 1;
localparam LOW = 0;

// State for receving
reg [1:0] receiving_state;

// State names
localparam idle = 0, receiving_meta_packet_info = 1;, receiving_packet_prefix = 2, receiving_packet_data = 3;

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
        packet_prefix <= 64'd0;;
        packet_data <= 256'd0;
    end
    else begin
        case (receiving_state)
            idle: begin
                RX_valid <= 0;
                packet_meta_data <= 0;
                packet_prefix <= 0;;
                packet_data <= 0;
                meta_data_count <= 7;
                prefix_count <= 63;
                data_count <= 255;

                // Wait for miso to go low (start bit)
                if (~miso) begin
                    receiving_state <= receiving;
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
                        receiving_state <= idle;
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

                // Time to move states and let FIB know that the data packet is ready!
                if (data_count == 0) begin
                    RX_valid <= HIGH;
                    receiving_state <= idle;
                end
                packet_data[data_count] <= miso;
                data_count <= data_count - 1;
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
reg [7:0]    packet_meta_data_input_save,
reg [63:0]   packet_prefix_input_save,
reg [255:0]  packet_data_input_save,

parameter send_meta_data = 1, send_prefix = 2, send_data = 3;
reg [1:0] transmitting_state;

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
        case (transmitting_state):
            idle: begin
                // Set counts to MSB of each registers
                meta_data_input_count <= 7;
                prefix_input_count <= 63;
                data_input_count <= 255;
                transferring_data_packet <= LOW; // Default to low

                if (TX_valid) begin
                    // Send start bit to start transfer and change states
                    mosi <= LOW;
                    receiving_state <= send_meta_data

                    // Save data to transfer since it is only valid for 1 clk cycle
                    packet_meta_data_input_save <= packet_meta_data_input;
                    packet_data_input_save <= packet_data_input;
                    packet_prefix_input_save <= packet_prefix_input;
                end
                // Keep data line high (so the interface knows nothing is transferring)
                else begin
                    mosi <= HIGH;
                end
            end 
            send_meta_data: begin
                if (meta_data_count == 0) begin
                    transmitting_state <= send_prefix;
                end 
                else if (meta_data_count == 6) begin
                    transferring_data_packet <= ~packet_meta_data_input_save[meta_data_input_count]; // See if the packet being transferred is a data packet, so we know what we are transferring
                end
                mosi <= packet_meta_data_input_save[meta_data_input_count];
                meta_data_input_count <= meta_data_input_count - 1;
            end
            send_prefix: begin
                if (prefix_input_count == 0) begin
                    // Check to see if we are transferring data
                    if (transferring_data_packet) begin
                        receiving_state <= send_data;
                    end
                    // If not, go back to idle
                    else begin
                        receiving_state <= idle;
                    end
                end
                mosi <= packet_prefix_input_save[prefix_input_count];
                prefix_input_count <= prefix_input_count - 1;
            end
            send_data: begin
                if (data_input_count == 0) begin
                    receiving_state <= idle;
                end
                mosi <= packet_data_input_save[data_input_count];
                data_input_count <= data_input_count - 1;
            end
        endcase
    end
endmodule