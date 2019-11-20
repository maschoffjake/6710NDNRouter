/*
    This module is used for creating the FIB table of the NDN router
*/

module fib(

    // PIT INPUTS
    input [63:0] pit_in_prefix,
    input [4:0] pit_in_len,
    input fib_out_bit,
    input start_send_to_pit,

    // DATA INPUTS
    input [4:0] data_in_len,
    input [63:0] data_in_prefix,
    input data_ready,
    input [7:0] data_in,

    // OVERALL INPUTS 
    input clk,
    input rst,

    // PIT OUTPUTS
    output [4:0] pit_out_len,
    output [63:0] pit_out_prefix,
    output prefix_ready,
    output [7:0] out_data,

    // DATA OUTPUTS
    output [63:0] prefix_out,
    output [4:0] len_out,
    output clk_out,
    output sync_clk,
);

/*
    Create a 2D array where there are 64 entries (1 for each possible length of the prefix),
    where there are 1024 entries in the array of size 65. Each of these entries store a valid bit of 1
    and the prefix associated with it
*/
reg hashTable[63:0][1023:0][64:0];

// Incoming packet logic



// Outgoing packet logic
parameter wait_state = 0, hash_value = 1, grab_value = 2, check_for_valid_prefix = 3;
reg [1:0] outgoing_state;
reg [1:0] outgoing_next_state;
reg [9:0] hash_value;

always@(fib_out_bit, rst) begin

    case (outgoing_state)
        wait_state: begin
            // Wait for flag to send data out!
            if (fit_out_bit)
                outgoing_next_state = grab_value;            
        end
        hash_value: begin
            
        end
        grab_value: begin
            
        end
        check_for_valid_prefix: begin
            
        end
    endcase

end

always @(posedge clk, rst) begin
	if (rst)
		outgoing_state <= 2'b00;
	else
		outgoing_state <= outgoing_next_state;		
	
end
endmodule