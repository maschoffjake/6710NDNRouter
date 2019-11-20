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

// INCOMING PACKET LOGIC

/* 
    Saving logic. Used for saving the incoming prefix data to the fib hash table.
*/
parameter wait_state = 0, get_hash = 1,  save_to_fib_table = 2;
reg [1:0] saving_logic_state;
reg [1:0] saving_logic_next_state;
reg [63:0] prefix_saving;
reg [5:0] len_saving;
reg [9:0] saving_logic_hash;

always@(data_ready, saving_logic_state) begin
    case (saving_logic_state)
        wait_state: begin
            if (data_ready)
                saving_logic_next_state <= get_hash;
            else
                saving_logic_next_state <= wait_state;
        end 
        get_hash: begin
            hash_prefix_in <= prefix_saving;
            hash_len_in <= len_saving;
            saving_logic_next_state = save_to_fib_table;
        end
        save_to_fib_table: begin
            hashTable[len_saving][saving_logic_hash] = {1'b1, prefix_saving};
            saving_logic_next_state = wait_state;
        end
        default:
            saving_logic_next_state = wait_state;
    endcase
end

always@(posedge clk, rst) begin
    if (rst)
        saving_logic_state <= wait_state;
    else
        saving_logic_state <= saving_logic_next_state;

    // Latch the prefix and len during wait state, so we can save for other states
    if (saving_logic_state == wait_state) begin
        prefix_saving <= data_in_prefix;
        len_saving <= data_in_len;
    end

    // Latch hash value after sending to values to hash table
    if (saving_logic_state == get_hash) begin
        saving_logic_hash <= hash;
    end
end

/* 
    Propogating data. Used for passing prefix to the PIT to ensure that the data was requested. It it was requested,
    pass the shift register data to the PIT table. Otherwise just drop it.
*/


// OUTGOING PACKET LOGIC

// Transmit data from PIT to outgoing data paths after finding longest matching prefix
parameter check_for_valid_prefix = 2;
reg [1:0] outgoing_state;
reg [1:0] outgoing_next_state;
reg [9:0] hash_value;
reg [63:0] prefix;
reg [5:0] len;
reg [64:0] hashtable_value;

always@(fib_out_bit, rst, outgoing_state) begin
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