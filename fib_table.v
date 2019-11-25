/*
    This module is used for creating the FIB table of the NDN router
    TODO: instead of sending size to the hash table, zero out the top bits
	  of the prefix we don't want
*/

module fib_table(

    // PIT INPUTS
    input [63:0] pit_in_prefix,
    input [7:0] pit_in_metadata,
    input fib_out_bit,
    input start_send_to_pit,
    input rejected,
    input [7:0] data_PIT_to_FIB,

    // DATA INPUTS
    input RX_valid,
    input [7:0] data_SPI_to_FIB,

    // OVERALL INPUTS 
    input clk,
    input rst,

    // PIT OUTPUTS
    //output reg [5:0] pit_out_len,
    output reg [63:0] pit_out_prefix,
    output reg prefix_ready,
    output reg [7:0] pit_out_metadata,

    // PIT DATA OUTPUT
    output reg [7:0] data_FIB_to_PIT;

    // DATA OUTPUTS
    output reg FIB_to_SPI_data_flag,
    output reg [7:0] data_FIB_to_SPI
);

localparam HIGH = 1, LOW = 0;

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
parameter wait_state = 0, receive_metadata = 1, receive_prefix = 2, receive_data = 3, wait_for_response = 4, pass_data_to_pit = 5;
reg [2:0] incoming_data_state;
reg [2:0] incoming_data_next_state;
reg [63:0] prefix_from_SPI;
reg [7:0] metadata_from_SPI;
reg [255:0] data_from_SPI;

// Flag used to keep track if we just received an interest or data packet
reg isInterestPacket;

// Count registers used for grabbing the correct bits
reg [2:0] prefix_byte_count;
reg [4:0] data_byte_count;

always@(RX_valid, incoming_data_state) begin
    // Default values (no latches)
    incoming_data_next_state <= 0;

    case (incoming_data_state)
        wait_state: begin
            if (RX_valid) begin
                // About to receive a packet, time to form packet
                incoming_data_next_state <= receive_metadata;
            end
            else begin
                incoming_data_next_state <= wait_state;
            end
        end 
        receive_metadata: begin
            incoming_data_next_state <= receive_prefix;
        end
        receive_prefix: begin
            if(prefix_byte_count == 0) begin
                if (isInterestPacket) begin
                    // If it's interest, we are done parsing and back to waiting!
                    incoming_data_next_state <= wait_state;
                end	
                else begin
                    // If it is a data packet we still need to receive that data
                    incoming_data_next_state <= receive_data;
                end
            end
            else begin
                // Continue receiving the prefix
                incoming_data_next_state <= receive_prefix;  
            end
        end
        receive_data: begin
            if(data_byte_count == 0) begin
                // Done reading from data, now we must wait for a rejection or accept flag from PIT
                incoming_data_next_state <= wait_for_response;
            end
            else begin
                // Continue receiving the data
                incoming_data_next_state <= receive_data;
            end
        end
        wait_for_response: begin
            // If the data packet wasn't requested (it was rejected) we can just go back to wait state
            if (rejected) begin
                incoming_data_next_state <= wait_state;
            end
            else if (start_send_to_pit) begin
                // The data was requested, so we must send it to the PIT!
                incoming_data_next_state <= pass_data_to_pit;
            end
            else begin
                incoming_data_next_state <= wait_for_response;
            end
        end
        pass_data_to_pit: begin
            if (data_byte_count == 0) begin
                // Done passing data to the PIT, back to waiting
                incoming_data_next_state <= wait_state;
            end
            else begin
                incoming_data_next_state <= pass_data_to_pit;
            end
        end
        default: begin
            incoming_data_next_state <= wait_state;
        end
    endcase
end

integer i;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        // Reset hash table values to all 0
        for (i=0; i<64; i=i+1) 
            hashTable[i] <= 10'b0000000000;
        incoming_data_state <= wait_state;
        prefix_from_SPI <= 0;
        metadata_from_SPI <= 0;
        data_from_SPI <= 0;
        prefix_byte_count <= 0;
        data_byte_count <= 0;
        isInterestPacket <= 0;
    end
    else begin
        case (incoming_data_state)
            wait_state: begin
                // Set counts to MSB of each registers
                prefix_byte_count <= 7;
                data_byte_count <= 31;
                isInterestPacket <= LOW; // Default to low

                // Continue moving states
                incoming_data_state <= incoming_data_next_state;
            end
			receive_metadata: begin
				metadata_from_SPI <= data_in;
				incoming_data_state <= incoming_data_next_state;
			end
			receive_prefix: begin
                if(prefix_byte_count == 0) begin
                    if (isInterestPacket) begin
                        // If this is an interest packet, we don't need to grab data from the line, so set the output lines and alert the PIT hash-table that there's a new input
                        prefix_ready <= HIGH;
                        pit_out_metadata <= metadata_from_SPI;
                        pit_out_prefix <= prefix_from_SPI;
                    end	
                else begin

                // Save the data for further use (shift in the 8-bits at a time as well)
                prefix_from_SPI <= (prefix_from_SPI << 8) + data_SPI_to_FIB;
                prefix_byte_count <= prefix_byte_count - 1;
                incoming_data_state <= incoming_data_next_state;
			end
			receive_data: begin
                data_from_SPI <= (data_from_SPI << 8) + data_SPI_to_FIB;
                data_byte_count <= data_byte_count - 1;
                incoming_data_state <= incoming_data_next_state;
			end 
            wait_for_response: begin
                incoming_data_state <= incoming_data_next_state;
                // Reset byte count, since we must now SEND 32 bytes
                data_byte_count <= 31;
            end
            pass_data_to_pit: begin
                // Shifting out upper 8-bits to the PIT
                data_FIB_to_PIT <= data_from_SPI[255:248];
                data_from_SPI <= data_from_SPI << 8;
                data_byte_count <= data_byte_count - 1;
            end
            default: begin
                incoming_data_state <= incoming_data_next_state;
            end
        endcase
    end

end

// OUTGOING PACKET LOGIC (only deals with interest packets being sent out from the user, since data packets are 
// handled by incoming state machine)
reg [63:0] hash_prefix_out;
reg [9:0] saved_hash_out;
wire [9:0] hash_value_out;
hash HASH_OUTGOING(hash_prefix_out, hash_value_out, clk, rst);

// Transmit longest matching prefix, total prefix, and meta data once longest prefix is found
parameter get_hash = 1, check_for_valid_prefix = 2, send_meta_data_to_spi = 3, send_total_prefix_to_spi = 4, send_longest_prefix_to_spi = 5, receive_data_from_PIT = 6, send_data_to_spi = 7;
reg [2:0] outgoing_state;
reg [2:0] outgoing_next_state;

// Save metadata and prefix once fib_out goes high
reg [63:0] prefix;
reg [5:0] length_of_prefix;
reg [7:0] metadata;
reg hashtable_value;

// Save the total content request for interest packet
reg [63:0] total_prefix;

// Counts for what byte has been sent out
reg [2:0] longest_matching_prefix_count;
reg [2:0] total_prefix_count;

// Reg used to tell when to also send data to the SPI module as well (for data packets)
reg send_data;
reg [255:0] data_to_send;

// Counter used to read in what byte we have read in from the PIT
reg [4:0] pit_input_byte_counter;

// Counter used to keep track of what byte we have sent to SPI from FIB for data packet contents
reg [4:0] fib_to_spi_data_count;

always@(fib_out_bit, outgoing_state) begin

    // Default values for no latch
    hashtable_value <= 0;
    outgoing_next_state <= 0;
    hash_prefix_out <= 0;


    case (outgoing_state)
        wait_state: begin
            // If fib out is high but not start to send, we know we that we have data from the user
            if (fib_out_bit && !start_send_to_pit) begin
                outgoing_next_state <= check_for_valid_prefix;
            end
            else if(fib_out_bit && start_send_to_pit) begin
                // Data packet incoming! Read data incoming from the PIT
                outgoing_next_state <= receive_data_from_PIT;
            end
            else begin
                outgoing_next_state <= wait_state;
            end
        end
        get_hash: begin
            // Set hash input
            hash_prefix_out <= prefix;
        end
        check_for_valid_prefix: begin
            hashtable_value <= hashTable[length_of_prefix][saved_hash_out];
            if (hashtable_value) begin
                // This is the longest matching prefix! Send out to the SPI and send the packet out
                outgoing_next_state <= send_meta_data_to_spi;
            end
            // Or if the length is 0, we know we didn't find a prefix so just send out a blank longest matching prefix
            else if (length_of_prefix == 0) begin
                outgoing_next_state <= send_meta_data_to_spi;
            end 
            else begin
                // Decrement the length by 1 and set the current bit to 0 (so hash changes to correct value) THIS IS DONE IN SEQUENTIAL BLOCK
                // Go back to get hash state since we still need to find the right prefix
                outgoing_next_state <= get_hash;
            end
        end
        send_meta_data_to_spi: begin
            outgoing_next_state <= send_total_prefix_to_spi;
        end
        send_total_prefix_to_spi: begin
            if (total_prefix_count == 0) begin
                // Done sending the total prefix
                if (data_packet) begin
                    // Now need to send out the data, not the longest matching prefix, since it is a data packet
                    outgoing_next_state <= send_data_to_spi;
                end
                else begin
                    // Interest packet, so just send out longest matching prefix as well
                    outgoing_next_state <= send_longest_prefix_to_spi; 
                end 
            end
            else begin
                outgoing_next_state <= send_total_prefix_to_spi;
            end
        end
        send_longest_prefix_to_spi: begin
            if (longest_matching_prefix_count == 0) begin
                // Done sending longest matching prefix, back to idle
                outgoing_next_state <= idle;
            end
            else begin
                outgoing_next_state <= send_longest_prefix_to_spi;
            end
        end
        receive_data_from_PIT: begin
            // Done receiving data
            if (pit_input_byte_counter == 0) begin
                // Now send the meta data, prefix, and data, so set the next state to send_meta_data_to_spi so we can begin outgoing data push
                outgoing_next_state <= send_meta_data_to_spi;
            end
            else begin
                outgoing_next_state <= receive_data_from_PIT;
            end
        end
        send_data_to_spi: begin
            if (fib_to_spi_data_count == 0) begin
                // Done sending data, back to idle
                outgoing_next_state <= wait_state;
            end
            else begin
                outgoing_next_state <= send_data_to_spi;
            end
        end
        default: begin
            outgoing_next_state <= wait_state;
        end
    endcase
end


always @(posedge clk, posedge rst) begin
	if (rst) begin
		outgoing_state <= 0;
        outgoing_next_state <= 0;
        prefix <= 0;
        metadata <= 0;
        hashtable_value <= 0;
        saved_hash_out <= 0;
        total_prefix <= 0;
        total_prefix_count < 0;
        longest_matching_prefix_count <= 0;
        data_packet <= 0;
        data_to_send <= 0;
        pit_input_byte_counter <= 0;
        fib_to_spi_data_count <= 0;
    end;
    else begin
        case (outgoing_state)
            wait_state: begin
                // Grab the data from the PIT
                prefix <= pit_in_prefix;
                length_of_prefix <= pit_in_metadata[5:0];
                outgoing_state <= outgoing_next_state;

                // Save the total prefix so we can include that in the interest packet and also the metadata
                total_prefix <= pit_in_prefix;
                metadata <= pit_in_metadata;

                // Intialize the counts for when we send the data to the SPI
                total_prefix_count <= 7;
                longest_matching_prefix_count <= 7;

                // Default to no data packet coming in
                data_packet <= 0;

                // Initialize pit count to MSB for reading in data from PIT incase there is a data packet
                pit_input_byte_counter <= 31;
                fib_to_spi_data_count <= 31;
            end
            get_hash: begin
                // Save the hash value on clk edge
                saved_hash_out <= hash_value_out;
                outgoing_state <= outgoing_next_state;
            end
            check_for_valid_prefix: begin
                // If the correct value was not found...
                if (outgoing_next_state != send_meta_data_to_spi) begin
                    // Set the current bit to 0 (to decrement it) and decrement our length
                    prefix[length_of_prefix] <= 0;
                    length_of_prefix <= length_of_prefix - 1;
                end
                else begin
                    // Otherwise we have the correct values and we need to send them to spi to send out, let SPI know we are sending data next cycle
                    FIB_to_SPI_data_flag <= 1;
                    outgoing_state <= outgoing_next_state;
                end
            end
            send_meta_data_to_spi: begin
                data_FIB_to_SPI <= metadata;
                outgoing_state <= outgoing_next_state;
            end
            send_total_prefix_to_spi: begin
                // Shifting 8 bits at a time
                data_FIB_to_SPI <= total_prefix[63:56]; // Shifting MSB
                total_prefix <= total_prefix << 8;
                outgoing_state <= outgoing_next_state;
                total_prefix_count <= total_prefix_count - 1;
            end
            send_longest_prefix_to_spi: begin
                // Shifting 8 bits at a time
                data_FIB_to_SPI <= prefix[63:56]; // Shifting MSB
                prefix <= prefix << 8;
                outgoing_state <= outgoing_next_state;
                longest_matching_prefix_count <= longest_matching_prefix_count - 1;
            end
            receive_data_from_PIT: begin
                data_packet <= HIGH;
                data_to_send <= (data_to_send << 8) + data_PIT_to_FIB;
                outgoing_state <= outgoing_next_state;
                pit_input_byte_counter <= pit_input_byte_counter - 1;
            end
            send_data_to_spi: begin
                // Shifting 8 bits at a time
                data_FIB_to_SPI <= data_packet[255:248];    // Shifting 8 MSB
                data_packet <= data_packet << 8;
                outgoing_state <= outgoing_next_state;
                fib_to_spi_data_count <= fib_to_spi_data_count - 1;
            end
            default: begin
                outgoing_state <= outgoing_next_state;
            end
    endcase
    end
end
endmodule