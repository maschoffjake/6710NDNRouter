module fib_table_testbench ();

// PIT INPUTS
reg [63:0] pit_in_prefix;
reg [5:0] pit_in_len;
reg fib_out_bit;
reg start_send_to_pit;
reg rejected;

// DATA INPUTS
reg [5:0] data_in_len;
reg [63:0] data_in_prefix;
reg data_ready;
reg [7:0] data_in;

// OVERALL INPUTS 
reg clk;
reg rst;

// PIT OUTPUTS
wire [5:0] pit_out_len;
wire [63:0] pit_out_prefix;
wire prefix_ready;
wire [7:0] out_data;

// DATA OUTPUTS
wire [63:0] longest_matching_prefix;
wire [5:0] longest_matching_prefix_len;
wire clk_out;

// Values used for simulation
reg start_outgoing_packet_simulation;
reg start_incoming_packet_simulation;
reg [63:0] prefix_value;
reg [5:0] prefix_length;

fib DUT (
    .pit_in_prefix(pit_in_prefix),
    .pit_in_len(pit_in_len),
    .fib_out_bit(fib_out_bit),
    .start_send_to_pit(start_send_to_pit),
    .rejected(rejected),

    .data_in_len(data_in_len),
    .data_in_prefix(data_in_prefix),
    .data_ready(data_ready),
    .data_in(data_in),

    .clk(clk),
    .rst(rst),

    .pit_out_len(pit_out_len),
    .pit_out_prefix(pit_out_prefix),
    .prefix_ready(prefix_ready),
    .out_data(out_data),

    .longest_matching_prefix(longest_matching_prefix),
    .longest_matching_prefix_len(longest_matching_prefix_len),
    .clk_out(clk_out)
);

parameter HIGH = 1'b1;
parameter LOW = 1'b0;

initial begin
	// Reset and set all values to 0
	rst = HIGH;
    pit_in_prefix = LOW;
    pit_in_len = LOW;
    fib_out_bit = LOW;
    start_send_to_pit = LOW;
    rejected = LOW;
    data_in_len = LOW;
    data_in_prefix = LOW;
    data_ready = LOW;
    data_in = LOW;

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

    // Testing incoming logic
    prefix_value = 64'h0000FFFF0000FFFF;
    prefix_length = 6'd10;
    start_incoming_packet_simulation = HIGH;

    #100;
    start_incoming_packet_simulation = LOW;
end

initial begin
	// Create clock
	clk = 1'b0;
	#100;
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
