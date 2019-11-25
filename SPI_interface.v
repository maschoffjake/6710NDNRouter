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

// Able to send and receive up to 1024 bytes at a time
reg [9:0] RX_count;
reg [9:0] TX_count;

// Containers for packets
reg [7:0] packet_meta_data;
reg [63:0] packet_prefix;
reg [255:0] packet_data;

// Counts for registers (where to insert bits)
reg [2:0] meta_data_count;
reg [5:0] prefix_count;
reg [7:0] data_count;

localparam HIGH = 1;
localparam LOW = 0;

reg [1:0] receiving_state;

localparam idle = 0, receiving = 1;, receiving_data_packet = 2, receiving_interest_packet = 3;

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
                packet_meta_data <= 8'd0;
                packet_prefix <= 64'd0;;
                packet_data <= 256'd0;
                // Wait for miso to go low (start bit)
                if (~miso) begin
                    receiving_state <= receiving;
                end
                RX_count <= 0;
            end 
            receiving: begin
                // First bit of a packet is a filler bit, so grab second. If it's high, interest packet!
                if (RX_count == 1) begin
                    if (miso)
                        receiving_state <= receiving_interest_packet;
                    else
                        receiving_state <= receiving_data_packet;
                    // Set the packet type in the packet container
                    packet_meta_data[6] <= miso;
                end
                RX_count <= RX_count + 1'b1;
            end
            receiving_data_packet: begin
                if (RX_count == )

            end
            receiving_interest_packet: begin


            end
            default: begin
                receiving_state <= receiving_next_state;
            end
        endcase
    end
end

endmodule