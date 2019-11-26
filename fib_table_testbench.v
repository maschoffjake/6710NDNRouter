module fib_table_testbench ();

// PIT HASH TABLE --> FIB
reg [63:0] pit_in_prefix;
reg [7:0] pit_in_metadata;
reg rejected;

// PIT --> FIB
reg fib_out_bit;
reg start_send_to_pit;
reg [7:0] data_PIT_to_FIB;

// SPI --> FIB
reg RX_valid;
reg [7:0] data_SPI_to_FIB;

// OVERALL INPUTS 
reg clk;
reg rst;

// FIB --> PIT HASH TABLE
wire [63:0] pit_out_prefix;
wire prefix_ready;
wire [7:0] pit_out_metadata;

// FIB --> PIT
wire [7:0] data_FIB_to_PIT;

// FIB --> SPI
wire FIB_to_SPI_data_flag;
wire [7:0] data_FIB_to_SPI;

fib_table DUT (
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

reg [63:0]          prefix_value;
reg [7:0]           metadata_value;
reg [255:0]         data_value;
reg [327:0]		    data_packet;
reg [71:0]          interest_packet;

reg                 start_incoming_interest_packet;
reg                 start_incoming_data_packet;
reg                 start_outgoing_interest_packet;
reg                 start_outgoing_data_packet;

reg [2:0]           state;

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

    start_incoming_data_packet = LOW;
    start_incoming_interest_packet = LOW;
    start_outgoing_data_packet = LOW;
    start_outgoing_interest_packet = LOW;
	#100;
	rst = 1'b0;

    // Testing incoming logic (interest packet)!
    prefix_value = 64'h0000FFFF0000FFFF;
    metadata_value = 6'd112;
    interest_packet = {metadata_value, prefix_value};
    state = 0;
    start_incoming_interest_packet = HIGH;
    #20;
    start_incoming_interest_packet = LOW;
    #1000;
end

initial begin
	// Create clock
	clk = 1'b0;
	forever #10 clk = ~clk;
end

reg [10:0] bytes_sent;
// Used for simulating data coming from SPI to FIB (interest packet!)
always@(posedge clk) begin
    case (state)
        // Wait State
        0: begin
            if (start_incoming_interest_packet) begin
                RX_valid <= HIGH;
                state <= 1;
            end
            bytes_sent <= 0;
        end
        // Send data
        1: begin
            RX_valid <= LOW;
            if (bytes_sent == 8) begin
                state <= 0;
            end
            else begin
                data_SPI_to_FIB <= interest_packet[71:64];
                interest_packet <= interest_packet << 8;
                state <= 1;
            end
        end
        default: begin
            state <= 0;
        end 
    endcase
end

endmodule
