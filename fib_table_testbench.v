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
wire [63:0] prefix_out;
wire [5:0] len_out;
wire clk_out;

fib_table DUT (
    .pit_in_prefix(pit_in_prefix),
    .pit_in_len(pit_in_len),
    .fib_out_bit(fib_out_bit),
    .start_send_to_pit(start_send_to_pit),
    .rejected(rejected),

    .data_in_len(data_in_len),
    .data_in_prefix(data_in_prefix),
    .data_ready(data_ready),
    .data_in(data_in),

    .clk(clk)
    .rst(rst),

    .pit_out_len(pit_out_len),
    .pit_out_prefix(pit_out_prefix),
    .prefix_ready(prefix_ready),
    .out_data(out_data),

    .prefix_out(prefix_out),
    .len_out(len_out),
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
	#100;
	rst = 1'b0;
end

initial begin
	// Create clock
	clk = 1'b0;
	#100;
	forever #10 clk = ~clk;
end

endmodule
