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

*/
module spi_mcu(
    input sclk,
    input mosi,
    output mosi,
    input ss
);



endmodule 