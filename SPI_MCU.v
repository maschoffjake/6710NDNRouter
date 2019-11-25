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
    input sclk,
    input mosi,
    output miso,
    input ss,

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



endmodule 