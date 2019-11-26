module fib_table_testbench ();

// PIT HASH TABLE --> FIB
reg [63:0] pit_in_prefix,
reg [7:0] pit_in_metadata,
reg rejected,

// PIT --> FIB
reg fib_out_bit,
reg start_send_to_pit,
reg [7:0] data_PIT_to_FIB,

// SPI --> FIB
reg RX_valid,
reg [7:0] data_SPI_to_FIB,

// OVERALL INPUTS 
reg clk,
reg rst,

// FIB --> PIT HASH TABLE
wire [63:0] pit_out_prefix,
wire prefix_ready,
wire [7:0] pit_out_metadata,

// FIB --> PIT
wire [7:0] data_FIB_to_PIT,

// FIB --> SPI
wire FIB_to_SPI_data_flag,
wire [7:0] data_FIB_to_SPI

fib DUT (
    .pit_in_prefix(pit_in_prefix),
    .pit_in_metadata(pit_in_metadata),
    .rejected(rejected),

    .fib_out_bit(fib_out_bit),
    .start_send_to_pit(start_send_to_pit),
    .data_PIT_to_FIB(data_PIT_to_FIB),

    .RX_valid(RX_valid),
    .data_SPI_to_FIB(data_SPI_to_FIB),

    .clk(clk),
    .rst(rst),

    .pit_out_prefix(pit_out_prefix),
    .prefix_ready(prefix_ready),
    .pit_out_metadata(pit_out_metadata),

    .data_FIB_to_PIT(data_FIB_to_PIT),

    .FIB_to_SPI_data_flag(FIB_to_SPI_data_flag),
    .data_FIB_to_SPI(data_FIB_to_SPI)
);

parameter HIGH = 1'b1;
parameter LOW = 1'b0;

initial begin
	// Reset and set all values to 0
	rst = HIGH;
    pit_in_prefix = LOW;
    pit_in_metadata = LOW;
    rejected = LOW;
    fib_out_bit = LOW;
    start_send_to_pit = LOW;
    data_PIT_to_FIB = LOW;
    RX_valid = LOW;
    data_SPI_to_FIB = LOW;

    start_outgoing_packet_simulation = LOW;
    start_incoming_packet_simulation = LOW;
	#100;
	rst = 1'b0;

    // Testing outgoing logic!
    prefix_value = 64'h0000FFFF0000FFFF;
    prefix_length = 6'd10;
    start_outgoing_packet_simulation = HIGH;
    #20;
    start_outgoing_packet_simulation = LOW;
    #1000;

    // Testing incoming logic with rejection
    prefix_value = 64'h0000FFFF0000FFFF;
    prefix_length = 6'd10;
    start_incoming_packet_simulation = HIGH;
    #100;
    start_incoming_packet_simulation = LOW;
    #100;
    rejected = 1;
    #100;

    // Testing incoming logic with accepted packet
    prefix_value = 64'h0000FFFF0000FFFF;
    prefix_length = 6'd10;
    start_incoming_packet_simulation = HIGH;
    rejected = 0;
    #100;
    start_incoming_packet_simulation = LOW;
    #200;
    start_send_to_pit = 1;
    #100;
    start_send_to_pit = 0;

    // Testing outgoing logic, should get a cache hit!
    prefix_value = 64'h0000FFFF0000FFFF;
    prefix_length = 6'd10;
    start_outgoing_packet_simulation = HIGH;
    #20;
    start_outgoing_packet_simulation = LOW;
    #1000;
end

initial begin
	// Create clock
	clk = 1'b0;
	forever #10 clk = ~clk;
end

// Used for simulating the outgoing logic
always@(start_outgoing_packet_simulation) begin
    if (start_outgoing_packet_simulation == HIGH) begin
        pit_in_prefix <= prefix_value;
        pit_in_len <= prefix_length;
        fib_out_bit <= HIGH;
    end
    else begin
        pit_in_prefix <= 64'd0;
        pit_in_len <= 6'd0;
        fib_out_bit <= LOW;
    end
end

// Used for simulating the incoming logic
always@(start_incoming_packet_simulation) begin
    if (start_incoming_packet_simulation == HIGH) begin
        data_in_prefix <= prefix_value;
        data_in_len <= prefix_length;
        data_ready <= HIGH;
    end
    else begin
        data_in_prefix <= 64'd0;
        data_in_len <= 6'd0;
        data_ready <= LOW;
    end
end

endmodule
