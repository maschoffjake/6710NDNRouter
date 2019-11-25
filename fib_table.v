/*
    This module is used for creating the FIB table of the NDN router
    TODO: instead of sending size to the hash table, zero out the top bits
	  of the prefix we don't want
*/

module fib_table(

    // PIT INPUTS
    input [63:0] pit_in_prefix,
    input [5:0] pit_in_len,
    input fib_out_bit,
    input start_send_to_pit,
    input rejected,

    // DATA INPUTS
    input data_ready,
    input [7:0] data_in,

    // OVERALL INPUTS 
    input clk,
    input rst,

    // PIT OUTPUTS
    //output reg [5:0] pit_out_len,
    output reg [63:0] pit_out_prefix,
    output reg prefix_ready,
    output reg [7:0] out_data,

    // DATA OUTPUTS
    output reg [63:0] longest_matching_prefix,
    output reg [5:0] longest_matching_prefix_len,
    output reg ready_for_data
);

/*
    Create a 2D array where there are 64 entries (1 for each possible length of the prefix),
    where there are 1024 entries in the array. Each of these entries store a valid bit of 1
*/
reg [1023:0] hashTable[63:0];

/*
    Create a hashing unit in order to hash items. Creating its own hashing unit so we don't 
    run into resources attempting to use the same hashing unit at the same time. Need 2 different
    hashing modules, one for incoming and one for outgoing.
*/
reg [63:0] hash_prefix_in;
reg [9:0] saved_hash_in;
wire [9:0] hash_value_in;
hash HASH_INCOMING(hash_prefix_in, hash_value_in, clk, rst);


// INCOMING PACKET LOGIC

/* 
    Saving logic. Used for saving the incoming prefix data to the fib hash table.
*/
parameter wait_state = 0, receive_metadata = 1, receive_prefix = 2, receive_data = 3;
reg [1:0] incoming_data_logic_state;
reg [1:0] incoming_data_logic_next_state;
reg [63:0] prefix_from_SPI;
reg [7:0] metadata_from_SPI;
reg [255:0] data_from_SPI;
reg [2:0] prefix_byte_count;
reg [4:0] data_byte_count;
reg isDataPacket;

integer i;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        // Reset hash table values to all 0
        for (i=0; i<64; i=i+1) 
            hashTable[i] <= 10'b0000000000;
        saving_logic_state <= wait_state;
        prefix_from_SPI <= 0;
        metadata_from_SPI <= 0;
        data_from_SPI <= 0;
        prefix_byte_count <= 0;
        data_byte_count <= 0;
        isDataPacket <= 0;
    end
    else begin
        case (incoming_data_logic_state)
            wait_state: begin
                // Set counts to MSB of each registers
                prefix_input_count <= 8;
                data_input_count <= 32;
                transferring_data_packet <= LOW; // Default to low

                if (data_ready) begin
                    transmitting_state <= receive_metadata;
                end
            end
			receive_metadata: begin
				metadata_from_SPI <= data_in;
				transmitting_state <= receive_prefix;
			end
			receive_prefix: begin
				if(prefix_input_count > 0) begin
					packet_prefix_input_save <= (packet_prefix_input_save << 8) + data_in;
					prefix_input_count <= prefix_input_count - 1;
				end
				else begin
					transmitting_state <= packet_data;
				end
			end
			receive_data: begin
				if(prefix_data_count > 0) begin
					packet_data_input_save <= (packet_data_input_save << 8) + data_in;	
					prefix_data_count = prefix_data_count - 1;			
				end
				else begin
					transmitting_state <= send_meta_data;
				end
			end 
            default: 
        endcase
    end

end

// OUTGOING PACKET LOGIC
reg [63:0] hash_prefix_out;
reg [9:0] saved_hash_out;
wire [9:0] hash_value_out;
hash HASH_OUTGOING(hash_prefix_out, hash_value_out, clk, rst);

// Transmit data from PIT to outgoing data paths after finding longest matching prefix
parameter check_for_valid_prefix = 2'd2;
reg [1:0] outgoing_state;
reg [1:0] outgoing_next_state;
reg [63:0] prefix;
reg [5:0] len;
reg [5:0] next_len;
reg hashtable_value;

// Used for sending out interest packets and data packets
always@(fib_out_bit, start_send_to_pit, outgoing_state) begin
    // Ensure no latches
    longest_matching_prefix <= 0;
    longest_matching_prefix_len <= 0;
    hash_prefix_out <= 0;
    hashtable_value <= 0;
    next_len <= 0;

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
            hash_prefix_out <= prefix;
            outgoing_next_state <= check_for_valid_prefix;
        end
        check_for_valid_prefix: begin
            hashtable_value <= hashTable[len][saved_hash_out];
            if (hashtable_value) begin
                // Valid entry, forward to output and then enter wait state for another outgoing packet
                longest_matching_prefix <= prefix;
                longest_matching_prefix_len <= len;
                outgoing_next_state <= wait_state;
            end
            else begin
                // Not a valid entry, decrement the length and get a new hash
                next_len <= len - 1;
                outgoing_next_state <= get_hash;

                /* 
                    If no prefix has been found after parsing through the entire hashtable,
                    just forward a length of 0 so the interface knows that no prefix was found and
                    just broadcast/send to root NDN router
                */
                if (next_len == 0) begin
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

always @(posedge clk, posedge rst) begin
    // Next state logic
	if (rst)
		outgoing_state <= 2'b00;
    // Latch the prefix and len during wait state, so we can save for other states
    else if (outgoing_state == wait_state) begin
        prefix <= pit_in_prefix;
        len <= pit_in_len;
        outgoing_state <= outgoing_next_state;
    end
    // Latch hash during get_hash state to use during next state
    else if (outgoing_state == get_hash) begin
        saved_hash_out <= hash_value_out;
        outgoing_state <= outgoing_next_state;
    end
    else if (outgoing_state == transfer_data) begin
        len <= next_len - 1;
    end
	else
		outgoing_state <= outgoing_next_state;

end
endmodule