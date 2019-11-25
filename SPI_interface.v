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
module (

    // SPI interfaces
    output sclk,
    output mosi,
    input miso,
    output cs,

    // Overall inputs
    input clk,
    input rst,

    output reg       RX_valid,  // Valid pulse for 1 cycle for RX byte
    output reg [7:0] RX_byte,   // Byte received on MISO
    input            TX_valid,  // Valid pulse for 1 cycle for TX byte
    input  [7:0]     TX_byte,   // Byte to serialize to MOSI
);

// RX count used to grab the second bit of transmission to know the type of the packet
reg RX_count;

// Containers for packets
reg [7:0] packet_meta_data;
reg [63:0] packet_prefix;
reg [255:0] packet_data;

// Counts for registers (where to insert bits)
reg [2:0] meta_data_count;
reg [5:0] prefix_count;
reg [7:0] data_count;

// Flag for if the current packet being received is a interest/data
reg isInterestPacket;

localparam HIGH = 1;
localparam LOW = 0;

reg [1:0] receiving_state;

localparam idle = 0, receiving_meta_packet_info = 1;, receiving_packet_prefix = 2, receiving_packet_data = 3;

/* 
    Just assign the chip select low for now, since we are only interfacing with one interface.
    Could easily change this module to allow for more chip selects, so the chip could interface
    with multiple outgoing interfaces.
*/
assign cs = LOW;


always@(posedge clk, posedge rst) begin
    if (rst) begin
        RX_count <= 0;
        TX_count <= 0;
        RX_valid <= 0;
        RX_byte <= 0;
        receiving_state <= idle;
        receiving_next_state <= idle;
        packet_meta_data <= 8'd0;
        packet_prefix <= 64'd0;;
        packet_data <= 256'd0;
    end
    else begin
        case (receiving_state)
            idle: begin
                packet_meta_data <= 0;
                packet_prefix <= 0;;
                packet_data <= 0;
                meta_data_count <= 7;
                prefix_count <= 63;
                data_count <= 256;
                RX_count <= 0;

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

endmodule