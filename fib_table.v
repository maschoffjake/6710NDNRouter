/*
    This module is used for creating the FIB table of the NDN router
*/

module fib(

    // PIT INPUTS
    input [63:0] pit_in_prefix,
    input [5:0] pit_in_len,
    input fib_out_bit,
    input start_send_to_pit,

    // DATA INPUTS
    input [5:0] data_in_len,
    input [63:0] data_in_prefix,
    input data_ready,
    input [7:0] data_in,

    // HASH INPUTS
    input [9:0] hash,

    // OVERALL INPUTS 
    input clk,
    input rst,

    // PIT OUTPUTS
    output [5:0] pit_out_len,
    output [63:0] pit_out_prefix,
    output prefix_ready,
    output [7:0] out_data,

    // DATA OUTPUTS
    output [63:0] prefix_out,
    output [5:0] len_out,
    output clk_out,

    // HASH OUTPUTS
    output [63:0] hash_prefix_in,
    output [5:0] hash_len_in
);

/*
    Create a 2D array where there are 64 entries (1 for each possible length of the prefix),
    where there are 1024 entries in the array of size 65. Each of these entries store a valid bit of 1
    and the prefix data associated with it
*/
reg hashTable[5:0][9:0][64:0];

// Incoming packet logic



// Outgoing packet logic
parameter wait_state = 0, get_hash = 1, check_for_valid_prefix = 2;
reg [1:0] outgoing_state;
reg [1:0] outgoing_next_state;
reg [9:0] hash_value;
reg [63:0] prefix;
reg [5:0] len;
reg [64:0] hashtable_value;

always@(fib_out_bit, rst) begin
    case (outgoing_state)
        wait_state: begin
            // Wait for flag to send data out!
            if (fib_out_bit)
                outgoing_next_state <= get_hash;
            else
                outgoing_next_state <= wait_state;          
        end
        get_hash: begin
            // Set hash input values
            hash_prefix_in <= prefix;
            hash_len_in <= len;
            outgoing_next_state <= check_for_valid_prefix;
        end
        check_for_valid_prefix: begin
            hashtable_value = hashTable[len][hash_value];
            if (hashtable_value[64]) begin
                // Valid entry, forward to output and then enter wait state for another outgoing packet
                prefix_out <= prefix;
                len_out <= len;
                outgoing_next_state <= wait_state;
            end
            else begin
                // Not a valid entry, decrement the length and get a new hash
                len <= len - 1;
                outgoing_next_state <= get_hash;
            end
        end
        default:
            outgoing_next_state <= wait_state;
    endcase
end

always @(posedge clk, rst) begin
    // Next state logic
	if (rst)
		outgoing_state <= 2'b00;
	else
		outgoing_state <= outgoing_next_state;

    // Latch the prefix and len during wait state, so we can save for other states
    if (outgoing_state == wait_state) begin
        prefix <= pit_in_prefix;
        len <= pit_in_len;
    end

    // Latch hash during get_hash state to use during next state
    if (outgoing_state == get_hash) begin
        hash_value <= hash;
    end	
end
endmodule