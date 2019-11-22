/*
    This module is used for creating the FIB table of the NDN router
*/

module fib(

    // PIT INPUTS
    input [63:0] pit_in_prefix,
    input [5:0] pit_in_len,
    input fib_out_bit,
    input start_send_to_pit,
    input rejected,

    // DATA INPUTS
    input [5:0] data_in_len,
    input [63:0] data_in_prefix,
    input data_ready,
    input [7:0] data_in,

    // OVERALL INPUTS 
    input clk,
    input rst,

    // PIT OUTPUTS
    output reg [5:0] pit_out_len,
    output reg [63:0] pit_out_prefix,
    output reg prefix_ready,
    output reg [7:0] out_data,

    // DATA OUTPUTS
    output reg [63:0] longest_matching_prefix,
    output reg [5:0] longest_matching_prefix_len,
    output clk_out
);

/*
    Create a 2D array where there are 64 entries (1 for each possible length of the prefix),
    where there are 1024 entries in the array. Each of these entries store a valid bit of 1
*/
reg [9:0] hashTable[5:0];

// Used to reset the hashtable on reset
integer i;
always@(posedge rst)
  begin
    if (rst) 
        for (i=0; i<64; i=i+1) 
            hashTable[i] <= 10'b0000000000;
  end

/*
    Create a hashing unit in order to hash items. Creating its own hashing unit so we don't 
    run into resources attempting to use the same hashing unit at the same time. Only need one
    hashing unit for the FIB since outgoing and incoming packets won't collide.
*/
reg [63:0] hash_prefix_in;
reg [5:0] hash_len_in;
reg [9:0] saved_hash;
wire [9:0] hash_value;
hash HASH_INCOMING(hash_prefix_in, hash_len_in, hash_value, clk, rst);


// INCOMING PACKET LOGIC

/* 
    Saving logic. Used for saving the incoming prefix data to the fib hash table.
*/
parameter wait_state = 2'd0, get_hash = 2'd1,  save_to_fib_table = 2'd2;
reg [1:0] saving_logic_state;
reg [1:0] saving_logic_next_state;
reg [63:0] prefix_saving;
reg [5:0] len_saving;

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
            // Set the valid bit high
            hashTable[len_saving][saved_hash] = 1'b1;
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
        saved_hash <= hash_value;
    end
end

/* 
    Propogating data. Used for passing prefix to the PIT to ensure that the data was requested. It it was requested,
    pass the shift register data to the PIT table. Otherwise just drop it.
*/

// Assign the clk to the data output, for when transferring data so that they are synced
assign clk_out = clk;

parameter send_prefix_to_pit = 1, wait_for_pit = 2, transfer_data = 3; 
parameter size_of_data = 1024;  // Size of data in bytes
reg [1:0] propagating_data_state;
reg [1:0] propagating_data_next_state;
reg [63:0] prefix_propagating;
reg [5:0] len_propagating;
reg [9:0] bytes_sent;
reg [9:0] bytes_sent_next;

always@(data_ready, propagating_data_state) begin
    // Ensure no latches
    pit_out_prefix <= 0;
    pit_out_len <= 0;
    prefix_ready <= 0;
    bytes_sent_next <= 0;
    out_data <= 0;

    case (propagating_data_state)
        wait_state: begin
            if (data_ready)
                propagating_data_next_state <= send_prefix_to_pit;
            else
                propagating_data_next_state <= wait_state;
        end 
        send_prefix_to_pit: begin
            // Send the prefix data to the PIT to see if this data was requested.
            pit_out_prefix <= prefix_propagating;
            pit_out_len <= len_propagating;
            prefix_ready <= 1'b1;
            propagating_data_next_state <= wait_for_pit;
        end
        wait_for_pit: begin
            // Wait for either a rejection or send bit to know when to send the bit
            if (rejected) begin     
                // Rejection means don't transfer the data, so just go back to wait state
                propagating_data_next_state <= wait_state;
            end
            else if (start_send_to_pit) begin 
                propagating_data_next_state <= transfer_data;
            end
            else begin
                propagating_data_next_state <= wait_for_pit;
            end
        end
        transfer_data: begin
            if (bytes_sent == size_of_data) begin
                propagating_data_next_state <= wait_state;
            end
            else 
                propagating_data_next_state <= transfer_data;
                out_data <= data_in;
                bytes_sent_next <= bytes_sent + 1'b1;
        end
    endcase
end

always@(posedge clk, rst) begin
    if (rst)
        propagating_data_state <= wait_state;
    else
        propagating_data_state <= propagating_data_next_state;

    // Latch the prefix and len during wait state, so we can save for other states
    if (propagating_data_state == wait_state) begin
        prefix_propagating <= data_in_prefix;
        len_propagating <= data_in_len;
    end

    // Latch the bytes sent on each clk cycle
    bytes_sent <= bytes_sent_next;

end

// OUTGOING PACKET LOGIC

// Transmit data from PIT to outgoing data paths after finding longest matching prefix
parameter check_for_valid_prefix = 2'd2;
reg [1:0] outgoing_state;
reg [1:0] outgoing_next_state;
reg [63:0] prefix;
reg [5:0] len;
reg [64:0] hashtable_value;

always@(fib_out_bit, rst, outgoing_state) begin
    // Ensure no latches
    longest_matching_prefix <= 0;
    longest_matching_prefix_len <= 0;
    hash_prefix_in <= 0;
    hash_len_in <= 0;
    hashtable_value <= 0;

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
            hashtable_value = hashTable[len][saved_hash];
            if (hashtable_value[64]) begin
                // Valid entry, forward to output and then enter wait state for another outgoing packet
                longest_matching_prefix <= prefix;
                longest_matching_prefix_len <= len;
                outgoing_next_state <= wait_state;
            end
            else begin
                // Not a valid entry, decrement the length and get a new hash
                len <= len - 1;
                outgoing_next_state <= get_hash;

                /* 
                    If no prefix has been found after parsing through the entire hashtable,
                    just forward a length of 0 so the interface knows that no prefix was found and
                    just broadcast/send to root NDN router
                */
                if (len == 0) begin
                    longest_matching_prefix <= prefix;
                    longest_matching_prefix_len <= 0;
                    outgoing_next_state <= wait_state;
                end
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
    if (outgoing_state == get_hash)
        saved_hash <= hash_value;
    else 
        saved_hash <= 0;
end
endmodule