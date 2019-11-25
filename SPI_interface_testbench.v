module spi_interface_module();

// SPI interfaces
wire sclk;
wire mosi;
output reg miso;
wire cs;

// Overall inputs
output clk;
output reg rst;

// Receiving output
wire          RX_valid;  // Valid pulse for 1 cycle for RX byte to know data is ready
wire [7:0]    packet_meta_data;
wire [63:0]   packet_prefix;
wire [255:0]  packet_data;

// Transferring input
output reg               TX_valid;                   // Valid pulse for 1 cycle for TX byte
output reg [7:0]         packet_meta_data_input;     
output reg [63:0]        packet_prefix_input;
output reg [255:0]       packet_data_input;

// Instantiate the module
spi_interface spi_interface_module(
    .sclk(sclk),
    .mosi(mosi),
    .miso(miso),
    .cs(cs),
    .clk(clk),
    .rst(rst),
    .RX_valid(RX_valid),
    .packet_meta_data(packet_meta_data),
    .packet_prefix(packet_prefix),
    .packet_data(packet_data),
    .TX_valid(TX_valid),
    .packet_data_input(packet_data_input),
    .packet_prefix_input(packet_prefix_input),
    .packet_data_input(packet_data_input)
);

/*
    VALUES USED FOR SIMULATION
*/
reg start_incoming_packet;
reg start_outgoing_packet;

reg [7:0]         packet_meta_data_test;     
reg [63:0]        packet_prefix_test;
reg [255:0]       packet_data_test;


initial begin
    TX_valid = 0;
    packet_meta_data_input = 0;
    packet_prefix_input = 0;
    packet_data_input = 0;
    start_incoming_packet = 0;
    start_outgoing_packet = 0;
    rst = 0;
    #10;
    rst = 1;
    #10;
    rst = 0;
    #20;

    // Start outgoing packet
    packet_meta_data_test = 8'b00101000;
    packet_prefix_test = 64'd129;
    packet_data_test = "here is data";
    start_outgoing_packet = 1;
end

always@(posedge start_incoming_packet) begin
    TX_valid <= 1;
    packet_meta_data_input <= packet_meta_data_test;     
    packet_prefix_input <= packet_prefix_test;
    packet_data_input <= packet_data_test;
    #20;
    TX_valid <= 0;
end

initial begin
	// Create clock
	clk = 1'b0;
	#100;
	forever #10 clk = ~clk;
end

endmodule
